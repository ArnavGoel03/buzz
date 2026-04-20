import SwiftUI

struct OrganizationEventRow: View {
    let event: Event

    var body: some View {
        HStack(spacing: BuzzSpacing.md) {
            dateBlock
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(BuzzFont.bodyEmphasis)
                    .foregroundStyle(BuzzColor.textPrimary)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10, weight: .semibold))
                    Text(event.location.name)
                        .font(BuzzFont.caption)
                }
                .foregroundStyle(BuzzColor.textSecondary)
            }
            Spacer()
            if event.isLive { LiveBadge() }
        }
        .padding(BuzzSpacing.md)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }

    private var dateBlock: some View {
        VStack(spacing: 1) {
            Text(monthShort)
                .font(BuzzFont.micro)
                .foregroundStyle(event.category.tint)
            Text(dayNumber)
                .font(BuzzFont.title2)
                .foregroundStyle(BuzzColor.textPrimary)
            Text(timeShort)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(BuzzColor.textTertiary)
        }
        .frame(width: 48, height: 60)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerSmall).fill(event.category.tint.opacity(0.12)))
    }

    // VULN #106 patch: format the date block in the venue's TZ. Otherwise an East Coast
    // student looking at a UCSD event sees the wrong day for late-night events.
    private var venueTZ: TimeZone {
        event.timezone.flatMap(TimeZone.init(identifier:)) ?? .current
    }
    private func df(_ format: String) -> DateFormatter {
        let f = DateFormatter(); f.dateFormat = format; f.timeZone = venueTZ; return f
    }
    private var monthShort: String { df("MMM").string(from: event.startsAt).uppercased() }
    private var dayNumber: String { df("d").string(from: event.startsAt) }
    private var timeShort: String { df("h:mma").string(from: event.startsAt).lowercased() }
}
