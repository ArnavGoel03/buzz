import SwiftUI

/// Premium event row used on the LiveNow feed. Category color bar on the left,
/// serif event title, mono timestamp, subtle glow when live. Mirrors the web's
/// BentoFeed cards — one visual language across iOS + macOS + buzz.app.
struct LiveEventRow: View {
    let event: Event

    var body: some View {
        HStack(spacing: 0) {
            // Category rim bar
            Rectangle()
                .fill(event.category.tint)
                .frame(width: 3)
                .frame(maxHeight: .infinity)

            VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
                topRow
                Text(event.title)
                    .font(BuzzFont.displaySM)
                    .foregroundStyle(BuzzColor.textPrimary)
                    .kerning(-0.3)
                    .lineLimit(2)
                bottomRow
            }
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.vertical, BuzzSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .rimCard()
        .overlay(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerLarge, style: .continuous)
                .stroke(event.isLive ? event.category.tint.opacity(0.45) : .clear, lineWidth: 1)
        )
    }

    private var topRow: some View {
        HStack(spacing: BuzzSpacing.xs) {
            CategoryPill(category: event.category, isLive: event.isLive)
            Spacer()
            Text(relativeLabel)
                .font(BuzzFont.monoSmall)
                .foregroundStyle(BuzzColor.textTertiary)
        }
    }

    private var bottomRow: some View {
        HStack(spacing: BuzzSpacing.md) {
            Label(event.location.name, systemImage: "mappin")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
                .lineLimit(1)
            Spacer()
            if event.rsvpCount > 0 {
                Label("\(event.rsvpCount)", systemImage: "person.fill")
                    .font(BuzzFont.monoSmall)
                    .foregroundStyle(BuzzColor.textTertiary)
            }
        }
    }

    private var relativeLabel: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: event.startsAt, relativeTo: Date())
            .uppercased()
    }
}

private struct CategoryPill: View {
    let category: EventCategory
    let isLive: Bool

    var body: some View {
        HStack(spacing: BuzzSpacing.xs) {
            if isLive {
                Circle().fill(BuzzColor.live).frame(width: 6, height: 6)
            }
            Text(category.shortName.uppercased())
                .font(BuzzFont.monoSmall)
                .tracking(0.8)
        }
        .padding(.horizontal, BuzzSpacing.sm)
        .padding(.vertical, 3)
        .background(
            Capsule().fill(category.tintSoft)
        )
        .foregroundStyle(category.tint)
    }
}

private extension EventCategory {
    var tintSoft: Color { tint.opacity(0.16) }
}
