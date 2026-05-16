import Foundation
import Security
import os

/// Wrapper around iOS Keychain for the Supabase auth token. Items are scoped to
/// `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` per the public privacy policy — the
/// device must be unlocked for the token to be readable, and the item never syncs to
/// iCloud (`kSecAttrSynchronizable=false` set explicitly on every op).
///
/// All operations return their `OSStatus` so callers can surface keychain-locked or
/// duplicate-item failures instead of producing a signed-in-but-tokenless user.
enum KeychainTokenStore {
    enum Item: String {
        case supabaseAccessToken
        case supabaseRefreshToken
    }

    @discardableResult
    static func save(_ value: String, for item: Item) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: item.rawValue,
            kSecAttrSynchronizable as String: false,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData as String: Data(value.utf8)
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess { logFailure("save", item, status) }
        return status
    }

    static func read(_ item: Item) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: item.rawValue,
            kSecAttrSynchronizable as String: false,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var out: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &out)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = out as? Data,
              let value = String(data: data, encoding: .utf8) else {
            logFailure("read", item, status)
            return nil
        }
        return value
    }

    @discardableResult
    static func delete(_ item: Item) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: item.rawValue,
            kSecAttrSynchronizable as String: false
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound { logFailure("delete", item, status) }
        return status
    }

    static func deleteAll() {
        for item in [Item.supabaseAccessToken, .supabaseRefreshToken] { delete(item) }
    }

    private static let log = Logger(subsystem: "com.arnavgoel.buzz", category: "keychain")
    private static func logFailure(_ op: String, _ item: Item, _ status: OSStatus) {
        let msg = (SecCopyErrorMessageString(status, nil) as String?) ?? "OSStatus \(status)"
        log.error("keychain \(op) \(item.rawValue, privacy: .public) failed: \(msg, privacy: .public)")
    }
}
