import Foundation
import os

/// Reads runtime secrets from `Secrets.plist` (gitignored). Never hardcode credentials in source —
/// they end up in your bundle binary and are easily extracted. Use `Secrets.plist.example`
/// as the template and create your own `Secrets.plist` locally.
enum SecretsLoader {
    private static let log = Logger(subsystem: "com.arnavgoel.buzz", category: "secrets")

    enum Key: String {
        case supabaseURL    = "SUPABASE_URL"
        case supabaseAnon   = "SUPABASE_ANON_KEY"
        case sentryDSN      = "SENTRY_DSN"
        case posthogAPIKey  = "POSTHOG_API_KEY"
    }

    static func value(_ key: Key) -> String? {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let value = plist[key.rawValue] as? String,
            !value.isEmpty,
            !value.contains("REPLACE_ME")
        else { return nil }
        return value
    }

    /// Per DEVELOP_RULES §1: never `preconditionFailure` in production. Missing secrets
    /// degrade gracefully — callers get an empty string and the affected feature reports
    /// a friendly error instead of SIGTRAP on launch. Debug builds still trip an
    /// assertion so the misconfig is loud locally.
    static func require(_ key: Key, file: StaticString = #file, line: UInt = #line) -> String {
        guard let v = value(key) else {
            log.error("Missing required secret \(key.rawValue, privacy: .public); falling back to empty.")
            assertionFailure("Missing required secret: \(key.rawValue). See Secrets.plist.example.", file: file, line: line)
            return ""
        }
        return v
    }
}
