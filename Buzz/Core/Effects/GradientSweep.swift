import SwiftUI

/// A slowly-rotating conic gradient used as a subtle ambient backdrop on the Live tab
/// header and prestige badges. The motion is slow enough to be almost subliminal but
/// signals "this screen is alive" at a glance.
struct GradientSweep: View {
    let tint: Color
    var speed: Double = 0.05            // revolutions per second

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let angle = Angle(degrees: (t * 360 * speed).truncatingRemainder(dividingBy: 360))
            AngularGradient(
                colors: [tint.opacity(0.35), tint.opacity(0.1), tint.opacity(0.35),
                         tint.opacity(0.05), tint.opacity(0.35)],
                center: .center,
                angle: angle
            )
            .blur(radius: 40)
        }
        .allowsHitTesting(false)
    }
}
