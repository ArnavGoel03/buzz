import CoreGraphics

/// Spacing + corner-radius constants. Aligned with `design/tokens.json` via `BuzzTokens`
/// so iOS, Android, and web all read the same values. The xxs/xxl/xxxl + cornerSmall/Pill
/// extras stay here because they're iOS-only nuances not worth re-rendering through the
/// token generator.
enum BuzzSpacing {
    static let xxs: CGFloat = 2
    static let xs:  CGFloat = BuzzTokens.spacingXS   // 4
    static let sm:  CGFloat = BuzzTokens.spacingSM   // 8
    static let md:  CGFloat = BuzzTokens.spacingMD   // 16
    static let lg:  CGFloat = BuzzTokens.spacingLG   // 24
    static let xl:  CGFloat = BuzzTokens.spacingXL   // 32
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 48

    static let cornerSmall:  CGFloat = BuzzTokens.radiusSM   // 10
    static let cornerMedium: CGFloat = BuzzTokens.radiusMD   // 14
    static let cornerLarge:  CGFloat = BuzzTokens.radiusLG   // 18
    static let cornerXL:     CGFloat = BuzzTokens.radiusXL   // 24
    static let cornerPill:   CGFloat = 999
}
