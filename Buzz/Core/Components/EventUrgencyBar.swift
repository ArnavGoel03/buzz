import SwiftUI

/// 2-pixel color-coded top strip that telegraphs *when* an event happens before the
/// eye even reaches the timestamp row. The whole point of Buzz is real-world time/place
/// density — vanity counts bury the signal, this surfaces it.
///
/// Mirror on web at `components/EventUrgencyBar.tsx`. Keep colors in sync.
struct EventUrgencyBar: View {
    let urgency: EventUrgency

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 2)
            .opacity(urgency == .past ? 0.3 : 1.0)
            .accessibilityHidden(true)
    }

    private var color: Color {
        switch urgency {
        case .live:     return Color(red: 1.00, green: 0.27, blue: 0.20)   // hot orange
        case .starting: return Color(red: 1.00, green: 0.58, blue: 0.00)   // amber
        case .soon:     return Color(red: 0.19, green: 0.82, blue: 0.35)   // green
        case .upcoming: return Color.white.opacity(0.12)
        case .past:     return Color.white.opacity(0.06)
        }
    }
}
