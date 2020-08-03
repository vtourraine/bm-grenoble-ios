//
//  Credentials.swift
//  bm
//
//  Created by Vincent Tourraine on 02/08/2019.
//  Copyright © 2019-2020 Studio AMANgA. All rights reserved.
//

import Foundation
import KeychainAccess

struct Credentials: Codable {
    let userIdentifier: String
    let password: String
}

extension Credentials {
    static let Key = "Credentials"

    func save(to userDefaults: UserDefaults) {
        let data = try? JSONEncoder().encode(self)
        userDefaults.set(data, forKey: Credentials.Key)
    }

    static func load(from userDefaults: UserDefaults) -> Credentials? {
        guard let encodedData = userDefaults.data(forKey: Credentials.Key) else {
            return nil
        }

        return try! JSONDecoder().decode(Credentials.self, from: encodedData)
    }

    static func remove(from userDefaults: UserDefaults) {
        userDefaults.removeObject(forKey: Credentials.Key)
    }
}

extension Credentials {
    static let UserIdentifierKey = "UserIdentifier"
    static let PasswordKey = "Password"

    func save(to keychain: Keychain) {
        keychain[Credentials.PasswordKey] = password
        keychain[Credentials.UserIdentifierKey] = userIdentifier
    }

    static func load(from keychain: Keychain) -> Credentials? {
        guard let userIdentifier = keychain[Credentials.UserIdentifierKey],
            let password = keychain[Credentials.PasswordKey] else {
                if let legacyCredentials = Credentials.load(from: .standard) {
                    // Migrate existing credentials from UserDefaults to Keychain
                    legacyCredentials.save(to: keychain)
                    Credentials.remove(from: .standard)
                    return legacyCredentials
                }

                return nil
        }

        return Credentials(userIdentifier: userIdentifier, password: password)
    }

    static func remove(from keychain: Keychain) {
        try? keychain.remove(Credentials.UserIdentifierKey)
        try? keychain.remove(Credentials.PasswordKey)
    }

    static func defaultKeychain() -> Keychain {
        return Keychain(service: "com.studioamanga.bmg", accessGroup: "77S3V3W24J.com.studioamanga.bmg.shared").synchronizable(true)
    }
}
