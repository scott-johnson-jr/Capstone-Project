//
//  SecureTokenManager.swift
//  Capstone Project
//
//  Created by user301577 on 9/28/26.
//

//
//  SecureTokenManager.swift
//  SwiftUIDemo
//
//  Created by user301577 on 9/15/26.
//

import Foundation
import Security

final class SecureTokenManager {
    static let shared = SecureTokenManager()
    
    private init() {}
    
    private let service = "com.scott-johnson.swift-demo.auth"
    
    func saveToken(_ token: String, key: String) -> Bool {
        
        guard let data = token.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
        
    }
    
    func getToken(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataRef)
        
        if status == errSecSuccess, let data = dataRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    
    func deleteToken(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
}

