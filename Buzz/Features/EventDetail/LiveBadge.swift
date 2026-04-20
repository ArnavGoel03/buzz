import SwiftUI

/// Pulsing "LIVE" indicator for events happening right now.
struct LiveBadge: View {
    @State private var on = false

    var body: some View {
        HStack(spacing: BuzzSpacing.xs) {
            Circle()
                .fill(BuzzColor.live)
                .frame(width: 7, height: 7)
                .opacity(on ? 1.0 : 0.4)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: on)
            Text("LIVE")
                .font(BuzzFont.micro)
                .foregroundStyle(BuzzColor.live)
        }
        .padding(.horizontal, BuzzSpacing.sm)
        .padding(.vertical, 4)
        .background(
            Capsule().fill(BuzzColor.live.opacity(0.18))
        )
        .onAppear { on = true }
    }
}
