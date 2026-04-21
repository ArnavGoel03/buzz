import SwiftUI

/// Parallax hero header — sticky on scroll, content drifts at 0.5x speed while
/// the background glow zooms slightly. Use to open a screen.
struct ParallaxHero<Content: View>: View {
    var height: CGFloat = 280
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            let y = proxy.frame(in: .global).minY
            let stretch = max(0, y)
            let speed: CGFloat = 0.4

            ZStack(alignment: .bottom) {
                MetalGradientBackground()
                    .frame(width: proxy.size.width, height: height + stretch)
                    .offset(y: -stretch)
                    .scaleEffect(1 + stretch / 800, anchor: .top)
                    .overlay(
                        LinearGradient(
                            colors: [.clear, BuzzColor.background.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                content()
                    .padding(.horizontal, BuzzSpacing.lg)
                    .padding(.bottom, BuzzSpacing.lg)
                    .offset(y: -y * speed)
            }
            .frame(height: height)
        }
        .frame(height: height)
    }
}
