import Foundation

/// Disk-backed cache for the last successful response per repository. Lets users see their
/// last-loaded events/orgs when they have no connectivity. TTL is long — stale beats empty.
///
/// Design note: FileManager isn't Sendable under Swift 6 strict concurrency. We re-fetch
/// `FileManager.default` inside each actor method instead of storing it as a property.
actor OfflineCache {
    static let shared = OfflineCache()

    private lazy var root: URL = {
        let fm = FileManager.default
        let base = fm.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("buzz-cache", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    struct Entry<T: Codable>: Codable {
        var savedAt: Date
        var value: T
    }

    func save<T: Codable & Sendable>(_ value: T, key: String) async {
        let entry = Entry(savedAt: Date(), value: value)
        guard let data = try? encoder.encode(entry) else { return }
        let url = root.appendingPathComponent(key + ".json")
        // VULN #29 patch: `.completeFileProtection` encrypts the file when device is locked.
        try? data.write(to: url, options: [.atomic, .completeFileProtection])
    }

    func load<T: Codable & Sendable>(_ type: T.Type, key: String, maxAge: TimeInterval = 86_400 * 7) -> T? {
        let url = root.appendingPathComponent(key + ".json")
        guard let data = try? Data(contentsOf: url),
              let entry = try? decoder.decode(Entry<T>.self, from: data),
              Date().timeIntervalSince(entry.savedAt) <= maxAge
        else { return nil }
        return entry.value
    }

    func clear() {
        try? FileManager.default.removeItem(at: root)
    }

    private nonisolated let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private nonisolated let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
