import Foundation
import Security

// MARK: - Token Storage using Keychain
final class TokenStorage {
    static let shared = TokenStorage()

    private let accessTokenKey  = "tembus.courier.accessToken"
    private let refreshTokenKey = "tembus.courier.refreshToken"
    private let userIdKey       = "tembus.courier.userId"

    private init() {}

    // MARK: - Access Token
    var accessToken: String? {
        get { retrieve(key: accessTokenKey) }
        set {
            if let value = newValue {
                save(key: accessTokenKey, value: value)
            } else {
                delete(key: accessTokenKey)
            }
        }
    }

    // MARK: - Refresh Token
    var refreshToken: String? {
        get { retrieve(key: refreshTokenKey) }
        set {
            if let value = newValue {
                save(key: refreshTokenKey, value: value)
            } else {
                delete(key: refreshTokenKey)
            }
        }
    }

    // MARK: - User ID
    var userId: String? {
        get { retrieve(key: userIdKey) }
        set {
            if let value = newValue {
                save(key: userIdKey, value: value)
            } else {
                delete(key: userIdKey)
            }
        }
    }

    func clearAll() {
        delete(key: accessTokenKey)
        delete(key: refreshTokenKey)
        delete(key: userIdKey)
    }

    // MARK: - Keychain Operations
    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        delete(key: key)
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData:   data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func retrieve(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrAccount:      key,
            kSecReturnData:       true,
            kSecMatchLimit:       kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
