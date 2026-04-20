import Foundation

/// Reads runtime secrets from `Secrets.plist` (gitignored). Never hardcode credentials in source —
/// they end up in your bundle binary and are easily extracted. Use `Secrets.plist.example`
/// as the template and create your own `Secrets.plist` locally.
enum SecretsLoader {
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

    static func require(_ key: Key, file: StaticString = #file, line: UInt = #line) -> String {
        guard let v = value(key) else {
            preconditionFailure("Missing required secret: \(key.rawValue). See Secrets.plist.example.", file: file, line: line)
        }
        return v
    }
}
