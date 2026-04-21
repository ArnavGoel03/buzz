import SwiftUI

/// "Bored Right Now" — the one-tap discovery primitive. Filters to events live or
/// starting in the next 30 min, within walking distance. Sorted by friend density,
/// then proximity. Polished to mirror buzz.app: serif display title, mono meta,
/// rim-lit cards, ambient gradient background.
struct LiveNowView: View {
    @Environment(AppServices.self) private var services
    @State private var liveEvents: [Event] = []
    @State private var loaded = false

    var body: some View {
        NavigationStack {
            ZStack {
                MetalGradientBackground(intensity: 0.6)
                    .overlay(BuzzColor.background.opacity(0.55))
                ScrollView {
                    VStack(alignment: .leading, spacing: BuzzSpacing.xl) {
                        hero
                        if liveEvents.isEmpty && loaded {
                            emptyState
                        } else {
                            eventList
                        }
                    }
                    .padding(.horizontal, BuzzSpacing.lg)
                    .padding(.top, BuzzSpacing.sm)
                    .padding(.bottom, BuzzSpacing.xxl)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar { ToolbarItem(placement: .principal) { WordmarkView(size: 20) } }
            .iosNavigationInline()
        }
        .task { await load() }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            Text(metaLabel)
                .font(BuzzFont.monoSmall)
                .tracking(1.4)
                .foregroundStyle(BuzzColor.textTertiary)
            RevealingText(
                text: liveEvents.isEmpty ? "Bored?" : "Tonight",
                font: BuzzFont.displayXL,
                foreground: BuzzColor.textPrimary
            )
            Text(heroSubtitle)
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var metaLabel: String {
        let now = Date().formatted(.dateTime.weekday(.wide))
        let live = liveEvents.filter { $0.isLive }.count
        return "\(now.uppercased()) · \(live) LIVE · 10 MIN WALK"
    }

    private var heroSubtitle: String {
        if liveEvents.isEmpty {
            return "Nothing live in walking distance right now. Check back in a bit."
        }
        return "Live right now or starting in the next 30 min. Tap one. Go."
    }

    private var eventList: some View {
        VStack(spacing: BuzzSpacing.md) {
            ForEach(liveEvents) { event in
                row(event)
                    .scrollRevealCard()
                    .magneticPress()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: BuzzSpacing.sm) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(BuzzColor.textTertiary)
            Text("Quiet hour")
                .font(BuzzFont.headline)
            Text("Try again in a bit, or open the full map.")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BuzzSpacing.xxl)
        .rimCard()
    }

    private func row(_ event: Event) -> some View {
        LiveEventRow(event: event)
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
