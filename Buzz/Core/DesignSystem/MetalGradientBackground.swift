import SwiftUI

/// Animated Metal shader background. Matches the web's WebGL shader visual —
/// flowing noise-warped gradient (deep blue → magenta → yellow highlights) that
/// runs on the GPU at <1ms per frame on Apple silicon.
struct MetalGradientBackground: View {
    let start: Date
    var intensity: Double = 1.0

    init(intensity: Double = 1.0) {
        self.start = Date()
        self.intensity = intensity
    }

    var body: some View {
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
