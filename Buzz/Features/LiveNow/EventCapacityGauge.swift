import SwiftUI

/// Real-time capacity meter. Fed by `event_live_capacity` view (check-ins vs capacity).
/// Classic social proof: "filling up fast" → urgency; "75% full" → others are there.
struct EventCapacityGauge: View {
    let checkedIn: Int
    let capacity: Int?

    private var pct: Double {
        guard let cap = capacity, cap > 0 else { return 0 }
        return min(1.0, Double(checkedIn) / Double(cap))
    }

    private var tint: Color {
        switch pct {
        case ..<0.3: return .green
        case ..<0.7: return BuzzColor.accent
        case ..<0.95: return .orange
        default: return BuzzColor.live
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
            HStack {
                label
                Spacer()
                HStack(spacing: 2) {
                    CountingInt(value: checkedIn, font: BuzzFont.captionBold)
                    if let cap = capacity {
                        Text(" / \(cap)")
                            .font(BuzzFont.captionBold)
                    }
                }
                .foregroundStyle(BuzzColor.textSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.10))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(tint)
                        .frame(width: max(6, geo.size.width * pct))
                }
            }
            .frame(height: 8)
        }
    }

    @ViewBuilder
    private var label: some View {
        if capacity == nil {
            Label("\(checkedIn) checked in", systemImage: "person.fill.checkmark")
                .font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
        } else if pct >= 0.95 {
            Text("At capacity").font(BuzzFont.captionBold).foregroundStyle(BuzzColor.live)
        } else if pct >= 0.7 {
            Text("Filling up fast").font(BuzzFont.captionBold).foregroundStyle(.orange)
        } else {
            Text("Live capacity").font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
        }
    }
}
