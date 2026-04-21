import SwiftUI

/// Soft radial glow behind hero surfaces — cheap depth, no motion cost. The color
/// is the app accent at ~12% so it reads as ambient warmth, not a prominent tint.
struct AmbientBackground: View {
    var body: some View {
        ZStack {
            BuzzColor.background
            RadialGradient(
                colors: [BuzzColor.accent.opacity(0.10), .clear],
                center: .init(x: 0.5, y: 0.15),
                startRadius: 50,
                endRadius: 620
            )
            .blur(radius: 30)
        }
        .ignoresSafeArea()
    }
}
