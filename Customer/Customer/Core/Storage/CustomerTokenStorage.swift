import Foundation
import Security

final class CustomerTokenStorage {
    static let shared = CustomerTokenStorage()

    private let accessTokenKey  = "tembus.customer.accessToken"
    private let refreshTokenKey = "tembus.customer.refreshToken"

    private init() {}

    var accessToken: String? {
        get { retrieve(key: accessTokenKey) }
        set { newValue != nil ? save(key: accessTokenKey, value: newValue!) : delete(key: accessTokenKey) }
    }

    var refreshToken: String? {
        get { retrieve(key: refreshTokenKey) }
        set { newValue != nil ? save(key: refreshTokenKey, value: newValue!) : delete(key: refreshTokenKey) }
    }

    func clearAll() {
        delete(key: accessTokenKey)
        delete(key: refreshTokenKey)
    }

    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        delete(key: key)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func retrieve(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(key: String) {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: key]
        SecItemDelete(query as CFDictionary)
    }
}
