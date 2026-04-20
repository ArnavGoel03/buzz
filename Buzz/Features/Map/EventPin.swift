import SwiftUI

/// Category-colored pin with live pulse, "starts soon" highlight, and count badge.
struct EventPin: View {
    let event: Event
    let isSelected: Bool

    var body: some View {
        ZStack {
            if event.isLive {
                pulse
            }
            Circle()
                .fill(event.category.tint)
                .frame(width: diameter, height: diameter)
                .overlay(
                    Circle().stroke(.white, lineWidth: isSelected ? 3 : 2)
                )
                .shadow(color: event.category.tint.opacity(0.6), radius: isSelected ? 12 : 6)
            Image(systemName: event.category.icon)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundStyle(.white)
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.spring(duration: 0.25, bounce: 0.4), value: isSelected)
    }

    private var diameter: CGFloat { isSelected ? 44 : 36 }
    private var iconSize: CGFloat { isSelected ? 18 : 15 }

    private var pulse: some View {
        Circle()
            .fill(event.category.tint.opacity(0.35))
            .frame(width: 60, height: 60)
            .modifier(PulseModifier())
    }
}

private struct PulseModifier: ViewModifier {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.7

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.4).repeatForever(autoreverses: false)) {
                    scale = 1.6
                    opacity = 0.0
                }
            }
    }
}
