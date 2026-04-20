import Foundation

/// Tracks the paper-flyer equivalent of digital adoption. Every digital RSVP replaces a
/// printed flyer the user would otherwise have grabbed; every org page view replaces a
/// printed poster. Estimates are intentionally conservative.
enum PaperImpact {
    /// Most college flyers are quarter-sheet handouts.
    static let sheetsPerFlyer: Double = 0.25

    /// Heuristic: 50 in-app org views replace one printed poster.
    static let viewsPerPoster: Double = 50

    static func sheetsSaved(rsvps: Int, orgViews: Int = 0) -> Double {
        Double(rsvps) * sheetsPerFlyer + (Double(orgViews) / viewsPerPoster)
    }

    /// Friendly label: "12 sheets" / "1.2k sheets" / "3.4 trees".
    static func friendly(_ sheets: Double) -> String {
        if sheets >= 8_500 {                        // ~1 tree = 8,500 sheets
            return String(format: "%.1f trees", sheets / 8_500)
        }
        if sheets >= 1_000 {
            return String(format: "%.1fk sheets", sheets / 1_000)
        }
        return "\(Int(sheets.rounded())) sheets"
    }
}
