//
//  KeychainHelper.swift
//  PiCloud2
//
//  Created for PiCloud project
//

import Foundation
import Security

/// Enum representing various keychain errors
enum KeychainError: Error {
    case duplicateItem
    case itemNotFound
    case invalidItemFormat
    case unexpectedStatus(OSStatus)
    case unhandledError(status: OSStatus)
}

/// A helper class for securely storing and retrieving credentials in the Keychain
class KeychainHelper {
    
    // MARK: - Properties
    
    /// The service identifier used for keychain items
    private let service: String
    
    // MARK: - Initialization
    
    /// Initialize with a service identifier
    /// - Parameter service: The service identifier for keychain items
    init(service: String = "com.picloud.credentials") {
        self.service = service
    }
    
    // MARK: - Public Methods
    
    /// Save a string value to the keychain
    /// - Parameters:
    ///   - value: The string value to save
    ///   - account: The account identifier (key)
    /// - Throws: KeychainError if saving fails
    func save(_ value: String, for account: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        
        // Create query dictionary
        var query = keychainQuery(for: account)
        query[kSecValueData as String] = data
        
        // Attempt to add the item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, update it
            try update(value, for: account)
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    /// Retrieve a string value from the keychain
    /// - Parameter account: The account identifier (key)
    /// - Returns: The stored string value
    /// - Throws: KeychainError if retrieval fails
    func retrieve(for account: String) throws -> String {
        // Create query dictionary
        var query = keychainQuery(for: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        // Execute the query
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unexpectedStatus(status)
        }
        
        // Extract and return the result
        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        
        return value
    }
    
    /// Delete an item from the keychain
    /// - Parameter account: The account identifier (key)
    /// - Throws: KeychainError if deletion fails
    func delete(for account: String) throws {
        let query = keychainQuery(for: account)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    // MARK: - Private Methods
    
    /// Update an existing keychain item
    /// - Parameters:
    ///   - value: The new string value
    ///   - account: The account identifier (key)
    /// - Throws: KeychainError if update fails
    private func update(_ value: String, for account: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidItemFormat
        }
        
        let query = keychainQuery(for: account)
        let updateQuery: [String: Any] = [kSecValueData as String: data]
        
        let status = SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    /// Create a standard keychain query dictionary
    /// - Parameter account: The account identifier (key)
    /// - Returns: A dictionary with the query parameters
    private func keychainQuery(for account: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
    }
}