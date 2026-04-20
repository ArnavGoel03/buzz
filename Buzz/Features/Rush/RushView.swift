import SwiftUI

/// Rush mode — appears in the app only during an active `rush_cycle` on the user's
/// campus. Grid of chapters with one-tap interest toggles. Mutual interest surfaces
/// events + unlocks bid day.
struct RushView: View {
    let cycle: RushCycle
    let chapters: [Organization]
    @State private var interested: Set<UUID> = []

    private let columns = [GridItem(.flexible(), spacing: BuzzSpacing.md),
                           GridItem(.flexible(), spacing: BuzzSpacing.md)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BuzzSpacing.lg) {
                    header
                    LazyVGrid(columns: columns, spacing: BuzzSpacing.md) {
                        ForEach(chapters) { org in
                            RushChapterCard(
                                organization: org,
                                isInterested: interested.contains(org.id),
                                onToggle: { toggle(org.id) }
                            )
                        }
                    }
                }
                .padding(BuzzSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Rush")
            .iosNavigationInline()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
            Text(cycle.name)
                .font(BuzzFont.title)
                .foregroundStyle(BuzzColor.textPrimary)
            Text(cycle.kind.displayName)
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.accent)
            Text("Tap chapters you're interested in. Mutual matches unlock bid day events.")
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textSecondary)
                .padding(.top, BuzzSpacing.xs)
        }
    }

    private func toggle(_ orgID: UUID) {
        Haptics.selection()
        if interested.contains(orgID) { interested.remove(orgID) }
        else { interested.insert(orgID) }
        // Production: upsert into public.rush_interests
    }
}
