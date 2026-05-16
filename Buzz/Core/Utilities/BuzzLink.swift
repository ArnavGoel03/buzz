import Foundation

/// Universal link builder. In production these become deep links via the Associated Domains
/// entitlement + apple-app-site-association at buzz.app, so taps open in-app rather than Safari.
enum BuzzLink {
    static let host = "buzz.app"
    /// Safe fallback used when interpolation would produce an invalid URL. Tapping it just
    /// opens the homepage — never a phishing surface.
    private static let homepage = URL(string: "https://buzz.app")! // invariant: hardcoded literal

    static func event(_ id: UUID) -> URL {
        URL(string: "https://\(host)/e/\(id.uuidString.lowercased())") ?? homepage
    }

    static func organization(handle: String) -> URL {
        // VULN #102 patch: percent-encode for defense-in-depth.
        let safe = handle.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return URL(string: "https://\(host)/o/\(safe)") ?? homepage
    }

    static func profile(handle: String) -> URL {
        // VULN #84 patch: strip ALL leading @, then percent-encode the rest.
        let stripped = handle.drop(while: { $0 == "@" })
        let safe = String(stripped).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return URL(string: "https://\(host)/u/\(safe)") ?? homepage
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
