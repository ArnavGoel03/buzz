import SwiftUI

/// Layered neutrals + OKLCH-matched categorical colors. Mirrors the web design
/// tokens so the iOS app and buzz.app feel like one product.
enum BuzzColor {
    // Background layers — warmer than flat black, reads premium
    static let background      = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let backgroundElev  = Color(red: 0.14, green: 0.14, blue: 0.17)
    static let surface         = Color(red: 0.17, green: 0.17, blue: 0.20)
    static let surface2        = Color(red: 0.21, green: 0.21, blue: 0.24)
    static let surface3        = Color(red: 0.25, green: 0.25, blue: 0.28)
    static let surfaceElevated = Color(red: 0.17, green: 0.17, blue: 0.20) // back-compat alias

    static let border        = Color.white.opacity(0.08)
    static let borderStrong  = Color.white.opacity(0.16)
    static let borderBright  = Color.white.opacity(0.24)

    static let textPrimary      = Color.white
    static let textSecondary    = Color.white.opacity(0.64)
    static let textTertiary     = Color.white.opacity(0.42)
    static let textQuaternary   = Color.white.opacity(0.24)

    // Signature accent — electric amber.
    static let accent        = Color(red: 1.00, green: 0.84, blue: 0.04)
    static let accentBright  = Color(red: 1.00, green: 0.90, blue: 0.20)
    static let accentPressed = Color(red: 0.92, green: 0.76, blue: 0.02)
    static let accentDim     = Color(red: 1.00, green: 0.84, blue: 0.04).opacity(0.14)

    // Category colors — uniform perceived brightness, mirror web's OKLCH values
    static let live     = Color(red: 1.00, green: 0.25, blue: 0.34)
    static let soon     = Color(red: 1.00, green: 0.58, blue: 0.00)
    static let later    = Color.white.opacity(0.50)
    static let party    = Color(red: 1.00, green: 0.28, blue: 0.66)
    static let food     = Color(red: 0.40, green: 0.84, blue: 0.44)
    static let greek    = Color(red: 0.68, green: 0.40, blue: 0.92)
    static let sports   = Color(red: 1.00, green: 0.58, blue: 0.00)
    static let academic = Color(red: 0.45, green: 0.78, blue: 0.98)
    static let career   = Color(red: 0.04, green: 0.52, blue: 1.00)
}
