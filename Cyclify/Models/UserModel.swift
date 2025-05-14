//
//  UserModel.swift
//  Cyclify
//
//  Created by Carolyn Yang on 2/24/25.
//
// Handles User Info
// Store non-sensitive data in @AppStorage
// Store sensitive data in the Keychain
import Foundation
import SwiftData
import Security

@Model
class UserModel {
    @Attribute(.unique) var email: String
    var firstName: String
    var lastName: String
    var weight: Double
    var weightUnit: String
    var heightFeet: Int
    var heightInches: Int
    var trainingLevel: Int
    var isLoggedIn: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \Ride.user)
    var rides: [Ride] = []

    init(email: String, firstName: String, lastName: String, weight: Double, weightUnit: String, heightFeet: Int, heightInches: Int, trainingLevel: Int = 1) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.weight = weight
        self.weightUnit = weightUnit
        self.heightFeet = heightFeet
        self.heightInches = heightInches
        self.trainingLevel = trainingLevel
    }

    func savePassword(_ password: String) {
        let passwordData = Data(password.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecValueData as String: passwordData
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving password: \(status)")
        }
    }
    
    func retrievePassword() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var retrievedData: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &retrievedData)
        if status == errSecSuccess, let data = retrievedData as? Data, let password = String(data: data, encoding: .utf8) {
            return password
        } else {
            print("Error retrieving password: \(status)")
            return nil
        }
    }
    
    func deletePassword() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: email
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            print("Error deleting password: \(status)")
        }
    }
    
    func checkPassword(_ password: String) -> Bool {
        let key = "password_\(email)"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let passwordData = result as? Data,
           let storedPassword = String(data: passwordData, encoding: .utf8) {
            return storedPassword == password
        }

        return false
    }

}
