//
//  KeychainService.swift
//  rmProApp
//
//  Created by William Castellano on 8/27/25.
//

import Foundation
import Security

class KeychainService {
    
    enum KeychainError: Error, LocalizedError {
        case duplicateEntry
        case unknown(OSStatus)
        case noPassword
        case unexpectedPasswordData
        case unableToSaveCredentials
        
        var errorDescription: String? {
            switch self {
            case .duplicateEntry:
                return "Duplicate keychain entry"
            case .unknown(let status):
                return "Keychain error: \(status)"
            case .noPassword:
                return "No credentials found"
            case .unexpectedPasswordData:
                return "Invalid credential format"
            case .unableToSaveCredentials:
                return "Unable to save credentials"
            }
        }
    }
    
    private let service = "com.rmProApp.api"
    private let accountKey = "RentManagerAPIAccount"
    
    // MARK: - Store Credentials Securely
    func saveCredentials(username: String, password: String) throws {
        // Create credential structure
        let credentials = [
            "username": username,
            "password": password
        ]
        
        guard let credentialsData = try? JSONEncoder().encode(credentials) else {
            throw KeychainError.unexpectedPasswordData
        }
        
        // Delete any existing credentials first
        try? deleteCredentials()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecValueData as String: credentialsData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    // MARK: - Retrieve Credentials
    func getCredentials() -> (username: String, password: String)? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let credentials = try? JSONDecoder().decode([String: String].self, from: data),
              let username = credentials["username"],
              let password = credentials["password"] else {
            return nil
        }
        
        return (username, password)
    }
    
    // MARK: - Delete Credentials
    func deleteCredentials() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
    
    // MARK: - Check if Credentials Exist
    var hasStoredCredentials: Bool {
        return getCredentials() != nil
    }
}
