import SwiftUI

/// Breathing-dot indicator for "live" surfaces — the tab bar flame, the RSVP count on
/// a filling-up event, the free-food banner, the SOS button (red). Tiny, but adds the
/// "this is alive, check it" subconscious signal.
struct PulsingDot: View {
    let color: Color
    var size: CGFloat = 8
    @State private var expanded = false

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.35))
                .frame(width: size * 2, height: size * 2)
                .scaleEffect(expanded ? 1.0 : 0.5)
                .opacity(expanded ? 0.0 : 0.6)
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                expanded = true
            }
        }
    }
}
