import SwiftUI

/// Pulsing "LIVE" indicator for events happening right now. The dot pulses, and
/// two small accent sparks periodically drift upward — signals energy without
/// being distracting.
struct LiveBadge: View {
    @State private var on = false
    @State private var sparkOn = false

    var body: some View {
        HStack(spacing: BuzzSpacing.xs) {
            ZStack {
                // Outer glow ring (expands + fades forever)
                Circle()
                    .stroke(BuzzColor.live.opacity(0.8), lineWidth: 1.2)
                    .frame(width: 7, height: 7)
                    .scaleEffect(on ? 2.4 : 1)
                    .opacity(on ? 0 : 0.9)
                    .animation(
                        .easeOut(duration: 1.4).repeatForever(autoreverses: false),
                        value: on
                    )
                // Core dot (alpha pulses)
                Circle()
                    .fill(BuzzColor.live)
                    .frame(width: 7, height: 7)
                    .opacity(on ? 1.0 : 0.45)
                    .animation(
                        .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                        value: on
                    )
            }
            .overlay(alignment: .top) {
                // Two tiny sparks drifting up + fading — signal of emission.
                ZStack {
                    spark(offsetX: -3, delay: 0.0)
                    spark(offsetX: 2,  delay: 0.6)
                }
                .offset(y: -14)
                .allowsHitTesting(false)
            }
            Text("LIVE")
                .font(BuzzFont.micro)
                .foregroundStyle(BuzzColor.live)
        }
        .padding(.horizontal, BuzzSpacing.sm)
        .padding(.vertical, 4)
        .background(Capsule().fill(BuzzColor.live.opacity(0.18)))
        .onAppear {
            on = true
            sparkOn = true
        }
    }

    private func spark(offsetX: CGFloat, delay: Double) -> some View {
        Circle()
            .fill(BuzzColor.live)
            .frame(width: 2, height: 2)
            .offset(x: offsetX, y: sparkOn ? -8 : 0)
            .opacity(sparkOn ? 0 : 0.9)
            .animation(
                .easeOut(duration: 1.2).repeatForever(autoreverses: false).delay(delay),
                value: sparkOn
            )
    }
}
