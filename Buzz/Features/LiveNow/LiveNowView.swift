import SwiftUI

/// "Bored Right Now" — the one-tap discovery primitive. Filters to events live or
/// starting in the next 30 min, within walking distance. Sorted by friend density first,
/// then proximity. Designed to replace the "what's even happening rn" group chat.
struct LiveNowView: View {
    @Environment(AppServices.self) private var services
    @State private var liveEvents: [Event] = []
    @State private var loaded = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BuzzSpacing.md) {
                    header
                    if liveEvents.isEmpty && loaded {
                        emptyState
                    } else {
                        ForEach(liveEvents) { event in
                            row(event)
                        }
                    }
                }
                .padding(BuzzSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Bored?")
            .iosNavigationInline()
        }
        .task { await load() }
    }

    private var header: some View {
        VStack(spacing: BuzzSpacing.xs) {
            Text("Live within 10 min walk")
                .font(BuzzFont.title)
                .foregroundStyle(BuzzColor.textPrimary)
            Text("Tap one. Go. No more group chat polling.")
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: BuzzSpacing.sm) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(BuzzColor.textTertiary)
            Text("Nothing live right now")
                .font(BuzzFont.headline)
            Text("Quiet hour. Try again in a bit, or check the full map.")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(BuzzSpacing.xxl)
    }

    private func row(_ event: Event) -> some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            HStack {
                Image(systemName: event.category.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(event.category.tint)
                Text(event.title)
                    .font(BuzzFont.headline)
                    .foregroundStyle(BuzzColor.textPrimary)
                Spacer()
                if event.isLive { LiveBadge() }
            }
            HStack(spacing: BuzzSpacing.sm) {
                Label(event.location.name, systemImage: "mappin")
                    .font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textSecondary)
                FriendsGoingBadge(friends: [], totalCount: event.rsvpCount)
            }
        }
        .padding(BuzzSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                .fill(LinearGradient(colors: [event.category.tint.opacity(0.18), BuzzColor.surface],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                .stroke(event.category.tint.opacity(0.35), lineWidth: 1)
        )
    }

    private func load() async {
        let coord = services.location.coordinate
        let all = (try? await services.events.events(near: coord, radiusMeters: 800)) ?? []
        let now = Date()
        liveEvents = all
            .filter { $0.isLive || ($0.startsAt > now && $0.startsAt < now.addingTimeInterval(1800)) }
            .sorted { $0.startsAt < $1.startsAt }
        loaded = true
    }
}
