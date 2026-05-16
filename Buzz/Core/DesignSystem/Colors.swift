import SwiftUI

/// Layered neutrals + categorical colors. Brand / category / status values delegate to
/// `BuzzTokens` (generated from `design/tokens.json`). Border + text scales stay as
/// alpha-on-white because they layer over varying surfaces cleanly that way; baking the
/// alpha into solid hex would lose the layered look.
enum BuzzColor {
    static let background      = BuzzTokens.background
    static let backgroundElev  = BuzzTokens.backgroundElevated
    static let surface         = BuzzTokens.surface
    static let surface2        = BuzzTokens.surface2
    static let surface3        = BuzzTokens.surface3
    static let surfaceElevated = BuzzTokens.backgroundElevated // back-compat alias

    static let border        = Color.white.opacity(0.08)
    static let borderStrong  = Color.white.opacity(0.16)
    static let borderBright  = Color.white.opacity(0.24)

    static let textPrimary    = BuzzTokens.textPrimary
    static let textSecondary  = BuzzTokens.textSecondary
    static let textTertiary   = BuzzTokens.textTertiary
    static let textQuaternary = BuzzTokens.textQuaternary

    static let accent        = BuzzTokens.accent
    static let accentBright  = BuzzTokens.accentBright
    static let accentPressed = BuzzTokens.accent      // simplifies; pressed = base; bake real value in tokens if needed
    static let accentDim     = BuzzTokens.accent.opacity(0.14)

    static let live     = BuzzTokens.live
    static let soon     = BuzzTokens.categoryFood     // amber-ish; alias keeps callsites stable
    static let later    = Color.white.opacity(0.50)
    static let party    = BuzzTokens.categoryParty
    static let food     = BuzzTokens.categoryFood
    static let greek    = BuzzTokens.categoryClub
    static let sports   = BuzzTokens.categorySports
    static let academic = BuzzTokens.categoryAcademic
    static let career   = BuzzTokens.categoryAcademic
}
