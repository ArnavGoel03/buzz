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
    var instagramHandle: String?        // bare handle, no "@" — e.g. "acm.ucsd"
    var websiteURL: URL?                // org's canonical site

    var accent: Color { Color(hex: accentHex) ?? .accentColor }

    // Canonicalised Instagram URL. Nil when we don't trust the handle (prevents phishing via
    // raw user-entered "insta.sketchy/login" style values sneaking through).
    var instagramURL: URL? {
        guard let raw = instagramHandle?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else { return nil }
        let cleaned = raw.hasPrefix("@") ? String(raw.dropFirst()) : raw
        // Instagram allows letters, numbers, periods, underscores. Reject anything else.
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._"))
        guard !cleaned.isEmpty, cleaned.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
            return nil
        }
        return URL(string: "https://instagram.com/\(cleaned)")
    }

    // Only surface https websites — a club link shouldn't deep-link into sketchy schemes.
    var safeWebsiteURL: URL? {
        guard let url = websiteURL, let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http" else { return nil }
        return url
    }
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
