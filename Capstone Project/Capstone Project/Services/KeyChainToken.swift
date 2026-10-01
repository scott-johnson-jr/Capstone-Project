//
//  KeyChainToken.swift
//  Capstone Project
//
//  Created by user301577 on 10/1/26.
//

import Foundation
import Security

final class KeychainTokenStore: TokenStore {

    private let service = "AdventureWorks"
    private let account = "authSession"

    func save(_ session: AuthSession) throws {
        let data = try JSONEncoder().encode(session)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)

        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(
            attributes as CFDictionary,
            nil
        )

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func load() throws -> AuthSession? {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?

        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess,
              let data = result as? Data else {
            throw KeychainError.loadFailed(status)
        }

        return try JSONDecoder().decode(
            AuthSession.self,
            from: data
        )
    }

    func clear() throws {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(
            query as CFDictionary
        )

        guard status == errSecSuccess ||
              status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

enum KeychainError: Error {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
}
