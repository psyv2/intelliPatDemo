import Foundation
import Security

protocol TokenStore {
    func save(_ token: AuthToken)
    func load() -> AuthToken?
    func clear()
}

/// Keychain-backed token storage. Tokens never belong in UserDefaults, which is
/// unencrypted, backed up, and readable on a jailbroken device.
final class KeychainTokenStore: TokenStore {
    private let service = "j.intellipatApp.auth"
    private let account = "accessToken"

    func save(_ token: AuthToken) {
        guard let data = try? JSONEncoder().encode(token) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(attributes as CFDictionary, nil)
    }

    func load() -> AuthToken? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data,
              let token = try? JSONDecoder().decode(AuthToken.self, from: data) else {
            return nil
        }
        return token
    }

    func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
