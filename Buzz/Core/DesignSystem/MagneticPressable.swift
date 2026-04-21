import SwiftUI

/// ScaleEffect + haptic-on-press modifier. Gives every interactive element a
/// "there's a real object underneath my finger" tactile feel. iOS pendant to
/// the web's magnetic button.
struct MagneticPressable: ViewModifier {
    @GestureState private var pressed = false
    var scale: CGFloat = 0.96
    var haptic: Bool = true

    func body(content: Content) -> some View {
        content
            .scaleEffect(pressed ? scale : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: pressed)
            .gesture(
                LongPressGesture(minimumDuration: 0.01)
                    .updating($pressed) { _, state, _ in
                        if !state && haptic { Haptics.selection() }
                        state = true
                    }
            )
    }
}

extension View {
    func magneticPress(scale: CGFloat = 0.96, haptic: Bool = true) -> some View {
        modifier(MagneticPressable(scale: scale, haptic: haptic))
    }
}
