import SwiftUI

/// Round 2 — Clery-act + crowdsourced safety alerts surfaced on the Live tab when active.
struct CampusAlertsRow: View {
    let severity: String
    let headline: String
    // Renamed from `body` → `message` to avoid clashing with `View.body`.
    let message: String?

    var body: some View {
        HStack(spacing: BuzzSpacing.md) {
            Image(systemName: severityIcon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(severityColor))
            VStack(alignment: .leading, spacing: 2) {
                Text(severity.uppercased()).font(BuzzFont.micro)
                    .foregroundStyle(severityColor).tracking(2)
                Text(headline).font(BuzzFont.bodyEmphasis).lineLimit(2)
                if let message {
                    Text(message).font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textSecondary).lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(BuzzSpacing.md)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(severityColor.opacity(0.15)))
        .overlay(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).stroke(severityColor, lineWidth: 1))
    }

    private var severityColor: Color {
        switch severity {
        case "emergency": BuzzColor.live
        case "warning":   .orange
        case "caution":   BuzzColor.accent
        default:          Color.blue
        }
    }
    private var severityIcon: String {
        switch severity {
        case "emergency": "exclamationmark.triangle.fill"
        case "warning":   "exclamationmark.circle.fill"
        case "caution":   "info.circle.fill"
        default:          "megaphone.fill"
        }
    }
}
