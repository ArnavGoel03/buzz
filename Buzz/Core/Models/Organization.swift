import SwiftUI

struct Organization: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var handle: String                  // e.g. "isa-ucsd"
    var tagline: String
    var description: String
    var category: OrganizationCategory
    var campus: String                  // e.g. "ucsd"
    var foundedYear: Int?
    var memberCount: Int
    var logoURL: URL?
    var coverURL: URL?
    var accentHex: String               // hex like "#FF2D92" — drives the org's visual identity
    var isVerified: Bool

    var accent: Color { Color(hex: accentHex) ?? .accentColor }
}

// Tiny hex helper colocated since it's only used by Organization right now.
extension Color {
    init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt64(s, radix: 16) else { return nil }
        self = Color(
            red:   Double((v >> 16) & 0xFF) / 255.0,
            green: Double((v >>  8) & 0xFF) / 255.0,
            blue:  Double( v        & 0xFF) / 255.0
        )
    }
}
