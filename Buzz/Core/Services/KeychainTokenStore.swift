import Foundation
import Security

/// Wrapper around iOS Keychain for storing the Supabase auth token. Items are scoped to
/// `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` so they never sync to iCloud and require
/// the device to be unlocked at least once after boot. `kSecAttrSynchronizable=false` is set
/// explicitly on every operation (VULN #107/108 patch) — Apple's defaults are correct today
/// but have shifted before, and we never want auth tokens leaking to iCloud Keychain.
enum KeychainTokenStore {
    enum Item: String {
        case supabaseAccessToken
        case supabaseRefreshToken
    }

    static func save(_ value: String, for item: Item) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: item.rawValue,
            kSecAttrSynchronizable as String: false,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
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
        guard SecItemCopyMatching(query as CFDictionary, &out) == errSecSuccess,
              let data = out as? Data,
              let value = String(data: data, encoding: .utf8) else { return nil }
        return value
    }

    static func delete(_ item: Item) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: item.rawValue,
            kSecAttrSynchronizable as String: false
        ]
        SecItemDelete(query as CFDictionary)
    }

    static func deleteAll() {
        for item in [Item.supabaseAccessToken, .supabaseRefreshToken] { delete(item) }
    }
}
