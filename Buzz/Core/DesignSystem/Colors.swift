import SwiftUI

enum BuzzColor {
    static let background = Color(red: 0.04, green: 0.04, blue: 0.06)
    static let surface = Color(red: 0.09, green: 0.09, blue: 0.12)
    static let surfaceElevated = Color(red: 0.14, green: 0.14, blue: 0.17)
    static let border = Color.white.opacity(0.08)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.64)
    static let textTertiary = Color.white.opacity(0.40)

    static let accent = Color(red: 1.0, green: 0.84, blue: 0.04)   // electric amber — "buzz"
    static let accentPressed = Color(red: 0.92, green: 0.76, blue: 0.02)

    static let live = Color(red: 1.0, green: 0.25, blue: 0.35)     // red-pink pulse for "happening now"
    static let soon = Color(red: 1.0, green: 0.62, blue: 0.04)     // orange for "starts soon"
    static let later = Color.white.opacity(0.5)
}
