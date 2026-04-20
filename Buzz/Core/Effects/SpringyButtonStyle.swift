import SwiftUI

/// The button feel — scale + haptic + brief glow on press. Applied globally; every
/// button in the app gets this unless it opts out. The 0.94 squeeze is the sweet spot
/// (tested against Airbnb, Instagram, BeReal taps — feels alive without exaggerated).
struct SpringyButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.94
    var haptic: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.55), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed && haptic { Haptics.selection() }
            }
    }
}

extension ButtonStyle where Self == SpringyButtonStyle {
    static var springy: SpringyButtonStyle { SpringyButtonStyle() }
    static var springyQuiet: SpringyButtonStyle { SpringyButtonStyle(haptic: false) }
}
