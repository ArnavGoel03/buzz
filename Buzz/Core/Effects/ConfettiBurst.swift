import SwiftUI

/// Dopamine-grade celebration particle burst. Emitted above the RSVP button the moment
/// the user commits to an event. 40 particles, gravity-accelerated, staggered lifetimes,
/// varying hues around the event's category tint. One-shot — removes itself.
struct ConfettiBurst: View {
    let tint: Color
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGVector
        var rotation: Double
        var rotationSpeed: Double
        var color: Color
        var size: CGFloat
        var birth: Date
    }

    var body: some View {
        TimelineView(.animation) { context in
            Canvas { ctx, size in
                let t = context.date.timeIntervalSinceReferenceDate
                for p in particles {
                    let dt = context.date.timeIntervalSince(p.birth)
                    let x = p.position.x + p.velocity.dx * dt
                    let y = p.position.y + p.velocity.dy * dt + 0.5 * 800 * dt * dt   // gravity
                    let age = min(1, dt / 1.4)
                    var c = ctx
                    c.opacity = 1 - age
                    c.translateBy(x: x, y: y)
                    c.rotate(by: .degrees(p.rotation + p.rotationSpeed * dt * 360))
                    c.fill(Rectangle().path(in: CGRect(x: -p.size / 2, y: -p.size / 2, width: p.size, height: p.size * 0.4)),
                           with: .color(p.color))
                    _ = t
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { burst() }
    }

    private func burst() {
        let hues: [Color] = [tint, .white, tint.opacity(0.75), BuzzColor.accent]
        particles = (0..<40).map { _ in
            Particle(
                position: CGPoint(x: 150, y: 30),
                velocity: CGVector(dx: .random(in: -220...220), dy: .random(in: -520...(-300))),
                rotation: .random(in: 0...360),
                rotationSpeed: .random(in: -2...2),
                color: hues.randomElement()!,
                size: .random(in: 6...12),
                birth: Date()
            )
        }
    }
}
