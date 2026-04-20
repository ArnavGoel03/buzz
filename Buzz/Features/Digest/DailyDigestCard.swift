import SwiftUI

/// Morning briefing displayed at the top of Live tab + delivered as 8am push. Top 3
/// events today that match the user's interests + friend graph, plus a headline number.
struct DailyDigestCard: View {
    let dateLabel: String
    let topEvents: [Event]

    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            HStack(spacing: BuzzSpacing.xs) {
                Image(systemName: "sun.horizon.fill")
                    .foregroundStyle(.orange)
                Text("Your day · \(dateLabel)")
                    .font(BuzzFont.captionBold)
                    .foregroundStyle(BuzzColor.textTertiary)
            }
            Text("\(topEvents.count) things worth showing up for.")
                .font(BuzzFont.title2)
                .foregroundStyle(BuzzColor.textPrimary)
            VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                ForEach(topEvents.prefix(3)) { event in
                    HStack(spacing: BuzzSpacing.sm) {
                        Image(systemName: event.category.icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(event.category.tint)
                        Text(event.title)
                            .font(BuzzFont.body)
                            .foregroundStyle(BuzzColor.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text(event.startsAt.friendlyStart(venueTimeZone: event.timezone))
                            .font(BuzzFont.caption)
                            .foregroundStyle(BuzzColor.textSecondary)
                    }
                }
            }
        }
        .padding(BuzzSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerLarge)
                .fill(LinearGradient(
                    colors: [.orange.opacity(0.18), BuzzColor.surface],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
        )
        .overlay(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerLarge)
                .stroke(.orange.opacity(0.3), lineWidth: 1)
        )
    }
}
