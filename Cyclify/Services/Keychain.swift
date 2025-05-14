//
//  Keychain.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/23/25.
//

import Foundation
import Security
import KeychainAccess

struct KeychainHelper {
    private let keychain = Keychain(service: "com.Cyclify")

    func savePassword(email: String, password: String) {
        keychain["password_\(email)"] = password
    }

    func checkPassword(email: String, password: String) -> Bool {
        keychain["password_\(email)"] == password
    }

    func clearPassword(email: String) {
        keychain["password_\(email)"] = nil
    }
}
