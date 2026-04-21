import SwiftUI

/// Cold-start splash. Wordmark materializes over the Metal shader gradient,
/// pulses once, then dismisses. Shown for ~1.4s on launch while services hydrate.
struct SplashView: View {
    var onFinish: () -> Void

    @State private var shown = false
    @State private var pulseOut = false

    var body: some View {
        ZStack {
            MetalGradientBackground(intensity: 1.2)
            VStack(spacing: BuzzSpacing.lg) {
                WordmarkView(size: 56)
                    .scaleEffect(shown ? 1 : 0.85)
                    .opacity(shown ? 1 : 0)
                    .blur(radius: shown ? 0 : 18)
                    .animation(.smooth(duration: 0.7), value: shown)

                Text("EVERY EVENT · ONE FEED")
                    .font(BuzzFont.monoSmall)
                    .tracking(3.2)
                    .foregroundStyle(BuzzColor.textTertiary)
                    .opacity(shown ? 1 : 0)
                    .offset(y: shown ? 0 : 8)
                    .animation(.smooth(duration: 0.6).delay(0.3), value: shown)
            }
            .scaleEffect(pulseOut ? 1.2 : 1)
            .opacity(pulseOut ? 0 : 1)
            .blur(radius: pulseOut ? 20 : 0)
        }
        .ignoresSafeArea()
        .onAppear {
            shown = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.smooth(duration: 0.55)) { pulseOut = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { onFinish() }
            }
        }
    }
}
