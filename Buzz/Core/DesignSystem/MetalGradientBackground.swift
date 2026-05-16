import SwiftUI

/// Animated Metal shader background. Matches the web's WebGL shader visual.
/// Honors Reduce Motion, Reduce Transparency, and Low Power Mode — collapses to a
/// static `BuzzColor.background` fill in any of those cases, per DEVELOP_RULES §8.
struct MetalGradientBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var start = Date()
    var intensity: Double = 1.0

    private var shouldFlatten: Bool {
        reduceMotion || reduceTransparency || ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    var body: some View {
        if shouldFlatten {
            BuzzColor.background.ignoresSafeArea()
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                let elapsed = timeline.date.timeIntervalSince(start)
                GeometryReader { proxy in
                    Rectangle()
                        .fill(BuzzColor.background)
                        .colorEffect(
                            ShaderLibrary.buzzGradient(
                                .float2(proxy.size.width, proxy.size.height),
                                .float(elapsed * intensity)
                            )
                        )
                }
            }
            .ignoresSafeArea()
        }
    }
}
