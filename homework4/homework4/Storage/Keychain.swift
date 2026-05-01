//
//  Keychain.swift
//  homework4
//
//  Created by Максим  on 30.04.2026.
//

import Foundation

final class Keychain {
    private let service = "com.myTradingApp.bundle"
    
    func save(key: String, value: String) -> Result<Void, Error> {
        guard let data = value.data(using: .utf8) else { return .failure(KeychainError.dataError) }
        
        let deleteQuery: [String : Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        let addQuery: [String : Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        guard SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess else { return .failure(KeychainError.savingError) }
        return .success(())
    }
    
    func read(key: String) -> String? {
        let query: [String : Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        return value
    }
    
    func delete(key: String) -> Result<Void, Error> {
        let deleteQuery: [String : Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        guard SecItemDelete(deleteQuery as CFDictionary) == errSecSuccess else { return .failure(KeychainError.deletionError ) }
        return .success(())
    }
}

// MARK: - KeychainError
enum KeychainError: Error {
    case savingError
    case deletionError
    case dataError
}
