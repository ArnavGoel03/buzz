import SwiftUI

/// Round 5 — "For You" feed. Ranked by EventRanker. Presented as the top section of
/// the Live tab instead of pure chronological order. First-session users get a
/// reasonable default (interest-agnostic) until they've picked interests + accumulated
/// check-in history.
struct ForYouFeed: View {
    let events: [Event]
    let onTap: (Event) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            HStack {
                Image(systemName: "sparkle")
                    .foregroundStyle(BuzzColor.accent)
                Text("For you")
                    .font(BuzzFont.title2)
                    .foregroundStyle(BuzzColor.textPrimary)
                Spacer()
                Text("Based on your interests + friends")
                    .font(BuzzFont.micro)
                    .foregroundStyle(BuzzColor.textTertiary)
            }
            ForEach(events.prefix(6)) { event in
                Button { onTap(event) } label: {
                    OrganizationEventRow(event: event)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
