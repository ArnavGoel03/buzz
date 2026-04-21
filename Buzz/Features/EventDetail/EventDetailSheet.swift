import SwiftUI

struct EventDetailSheet: View {
    @Environment(AppServices.self) private var services
    let event: Event
    let viewModel: MapViewModel

    var body: some View {
        ZStack(alignment: .top) {
            // Category-tinted Metal gradient bleeds into the top third as ambient chrome.
            MetalGradientBackground(intensity: 0.4)
                .overlay(
                    LinearGradient(
                        colors: [event.category.tint.opacity(0.35), BuzzColor.background],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(height: 260)
                .blur(radius: 30)
                .opacity(0.8)

            VStack(alignment: .leading, spacing: BuzzSpacing.lg) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: BuzzSpacing.lg) {
                        if !event.summary.isEmpty {
                            Text(event.summary)
                                .font(BuzzFont.body)
                                .foregroundStyle(BuzzColor.textPrimary)
                        }
                        metaBlock
                        if !event.tags.isEmpty { tagsRow }
                    }
                    .padding(.horizontal, BuzzSpacing.lg)
                }
                Spacer(minLength: 0)
                rsvpFooter
            }
            .padding(.top, BuzzSpacing.lg)
        }
        .presentationCornerRadius(32)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            HStack(spacing: BuzzSpacing.sm) {
                CategoryBadge(category: event.category, isOfficial: event.isOfficial)
                if event.isLive { LiveBadge() }
                Spacer()
                EventShareButton(event: event)
                ReportMenuButton(target: .event(event.id))
            }
            // Social proof — replaces just-a-count with friend faces. Production replaces
            // the empty `friends:` arg with the result of `friends_going_to_event` view.
            HStack(spacing: BuzzSpacing.sm) {
                FriendsGoingBadge(friends: [], totalCount: event.rsvpCount)
                AttendeePill(count: event.rsvpCount, capacity: event.capacity)
                Spacer()
            }
            RevealingText(text: event.title, font: BuzzFont.display, foreground: BuzzColor.textPrimary)
            Text("by \(event.hostName)")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
        }
        .padding(.horizontal, BuzzSpacing.lg)
    }

    private var metaBlock: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            EventMetaRow(icon: "clock.fill",
                         primary: event.startsAt.friendlyStart(venueTimeZone: event.timezone),
                         secondary: timeRange)
            EventMetaRow(icon: "mappin.and.ellipse",
                         primary: event.location.name,
                         secondary: event.location.address)
        }
    }

    private var tagsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BuzzSpacing.sm) {
                ForEach(event.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textSecondary)
                        .padding(.horizontal, BuzzSpacing.sm)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.06)))
                }
            }
        }
    }

    @Environment(AuthSession.self) private var auth
    @State private var showingSignIn = false

    private var rsvpFooter: some View {
        // VULN #38 patch: don't wrap RSVPButton in AuthGate (a Button-in-Button conflict
        // that swallows taps). Inline the auth check; show SignInSheet for guests.
        RSVPButton(
            status: viewModel.rsvps[event.id] ?? .notGoing,
            tint: event.category.tint,
            onTap: { _ in
                if auth.isAuthenticated {
                    rsvpGoing()
                } else {
                    Haptics.tap()
                    showingSignIn = true
                }
            }
        )
        .padding(.horizontal, BuzzSpacing.lg)
        .padding(.bottom, BuzzSpacing.xl)
        .sheet(isPresented: $showingSignIn) {
            SignInSheet()
                .presentationDetents([.medium, .large])
                .presentationBackground(.ultraThinMaterial)
        }
    }

    private func rsvpGoing() {
        let prior = viewModel.rsvps[event.id] ?? .notGoing
        let next: RSVPStatus = prior == .going ? .notGoing : .going
        Task {
            await viewModel.rsvp(to: event.id, status: next)
            // VULN #39 patch: only add to calendar if the RSVP actually persisted.
            // Previously we added even when the server rolled back, polluting the user's calendar.
            let landedAsGoing = (viewModel.rsvps[event.id] ?? .notGoing) == .going
            if next == .going, landedAsGoing {
                _ = await services.calendar.add(event)
            }
        }
    }

    private var timeRange: String {
        // VULN #105 patch: format in venue's TZ so cross-region viewers see the correct
        // local time. Suffix abbreviation when it differs from the user's TZ.
        let venueTZ = event.timezone.flatMap(TimeZone.init(identifier:)) ?? .current
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        df.timeZone = venueTZ
        let suffix = (venueTZ.identifier != TimeZone.current.identifier)
            ? " (\(venueTZ.abbreviation() ?? venueTZ.identifier))"
            : ""
        return "\(df.string(from: event.startsAt)) – \(df.string(from: event.endsAt))\(suffix)"
    }
}
