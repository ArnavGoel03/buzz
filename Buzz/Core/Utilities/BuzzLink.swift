import Foundation

/// Universal link builder. In production these become deep links via the Associated Domains
/// entitlement + apple-app-site-association at buzz.app, so taps open in-app rather than Safari.
enum BuzzLink {
    static let host = "buzz.app"

    static func event(_ id: UUID) -> URL {
        URL(string: "https://\(host)/e/\(id.uuidString.lowercased())")!
    }

    static func organization(handle: String) -> URL {
        // VULN #102 patch: percent-encode for defense-in-depth (schema CHECK keeps the
        // canonical form `[a-z0-9-]+`, but the link builder can't assume that's enforced
        // when invoked from mock data, tests, or future input paths).
        let safe = handle.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return URL(string: "https://\(host)/o/\(safe)")!
    }

    static func profile(handle: String) -> URL {
        // VULN #84 patch: strip ALL leading @ (not just one), then percent-encode the rest
        // so a maliciously crafted handle can't break out of the path component.
        let stripped = handle.drop(while: { $0 == "@" })
        let safe = String(stripped).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return URL(string: "https://\(host)/u/\(safe)")!
    }

    /// Before opening a scanned QR / pasted URL in-app, verify it actually belongs to Buzz —
    /// otherwise a hostile QR could redirect users to a lookalike phishing domain we'd then
    /// dutifully render with our app-chrome around it.
    enum Kind: Hashable, Sendable {
        case event(UUID)
        case organization(String)
        case profile(String)
    }

    static func validate(_ url: URL) -> Kind? {
        guard url.scheme == "https", url.host == host else { return nil }
        let parts = url.pathComponents.filter { $0 != "/" }
        guard parts.count == 2 else { return nil }
        switch parts[0] {
        case "e":
            if let id = UUID(uuidString: parts[1]) { return .event(id) }
        case "o":
            return .organization(parts[1])
        case "u":
            return .profile(parts[1])
        default: break
        }
        return nil
    }
}
