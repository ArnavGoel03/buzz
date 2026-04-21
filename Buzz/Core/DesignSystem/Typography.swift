import SwiftUI

/// Three typography systems carry the brand:
///   - **Display**: SF New York (system serif) for editorial headlines.
///   - **Sans**: SF Pro / SF Pro Rounded for body + UI chrome.
///   - **Mono**: SF Mono for timestamps, stats, IDs, keyboard hints.
///
/// Matches the web's Fraunces + Geist + Geist Mono pairing without bundling custom
/// fonts (Apple's built-ins are already top-tier).
enum BuzzFont {
    // Display (editorial, SF New York — Apple's serif with soft italics)
    static let displayXL = Font.system(size: 44, weight: .medium, design: .serif)
    static let display   = Font.system(size: 34, weight: .medium, design: .serif)
    static let displaySM = Font.system(size: 28, weight: .medium, design: .serif)

    // Core — SF Pro Rounded for headings gives a friendlier read than default SF
    static let largeTitle    = Font.system(size: 34, weight: .heavy,    design: .rounded)
    static let title         = Font.system(size: 26, weight: .bold,     design: .rounded)
    static let title2        = Font.system(size: 22, weight: .bold,     design: .rounded)
    static let headline      = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body          = Font.system(size: 15, weight: .regular,  design: .default)
    static let bodyEmphasis  = Font.system(size: 15, weight: .semibold, design: .default)
    static let caption       = Font.system(size: 13, weight: .medium,   design: .rounded)
    static let captionBold   = Font.system(size: 13, weight: .bold,     design: .rounded)
    static let micro         = Font.system(size: 11, weight: .semibold, design: .rounded)

    // Mono — SF Mono; tabular by default for numeric alignment
    static let mono          = Font.system(size: 13, weight: .medium, design: .monospaced)
    static let monoSmall     = Font.system(size: 11, weight: .medium, design: .monospaced)
    static let monoStat      = Font.system(size: 28, weight: .medium, design: .monospaced)
}
