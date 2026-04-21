import SwiftUI

/// Scroll-driven card entry — rotates, scales, and fades in from below as it
/// enters the viewport. Uses iOS 17+ `scrollTransition` so the animation is
/// synced to scroll position, not time.
struct ScrollRevealCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollTransition(axis: .vertical) { view, phase in
                view
                    .opacity(phase.isIdentity ? 1 : 0)
                    .scaleEffect(phase.isIdentity ? 1 : 0.92)
                    .offset(y: phase.isIdentity ? 0 : 24)
                    .blur(radius: phase.isIdentity ? 0 : 6)
            }
    }
}

extension View {
    func scrollRevealCard() -> some View { modifier(ScrollRevealCard()) }
}
