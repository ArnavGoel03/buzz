#if canImport(UIKit)
import UIKit
#endif

/// Cross-platform haptics. iOS / iPadOS get the Taptic Engine; macOS no-ops gracefully
/// (Macs have no Taptic Engine — we don't pretend otherwise).
@MainActor
enum Haptics {
    static func tap() {
        #if canImport(UIKit) && !os(visionOS)
        let g = UIImpactFeedbackGenerator(style: .light)
        g.prepare()
        g.impactOccurred()
        #endif
    }

    static func selection() {
        #if canImport(UIKit) && !os(visionOS)
        let g = UISelectionFeedbackGenerator()
        g.prepare()
        g.selectionChanged()
        #endif
    }

    static func success() {
        #if canImport(UIKit) && !os(visionOS)
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.success)
        #endif
    }

    static func warning() {
        #if canImport(UIKit) && !os(visionOS)
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.warning)
        #endif
    }

    static func heavy() {
        #if canImport(UIKit) && !os(visionOS)
        let g = UIImpactFeedbackGenerator(style: .heavy)
        g.prepare()
        g.impactOccurred()
        #endif
    }
}
