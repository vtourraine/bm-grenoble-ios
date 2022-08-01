//
//  Credentials.swift
//  BM Grenoble
//
//  Created by Tourraine, Vincent (ELS-HBE) on 01/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import Foundation
import KeychainAccess

struct Credentials: Codable {
    let username: String
    let password: String
}

extension Credentials {
    static let Key = "UserCredentials"

    func save(to keychain: Keychain) throws {
        let data = try JSONEncoder().encode(self)
        try keychain.set(data, key: Credentials.Key)
    }

    static func load(from keychain: Keychain) throws -> Credentials? {
        guard let encodedData = try keychain.getData(Credentials.Key) else {
            return nil
        }

        let session = try JSONDecoder().decode(Credentials.self, from: encodedData)
        return session
    }

    static func remove(from keychain: Keychain) throws {
        try keychain.remove(Credentials.Key)
    }
}

extension Credentials {
    static func defaultKeychain() -> Keychain {
        return Keychain(service: "com.studioamanga.bmg", accessGroup: "77S3V3W24J.com.studioamanga.bmg.shared").synchronizable(true)
    }

    static func sharedCredentials() -> Credentials? {
        return try? load(from: Credentials.defaultKeychain())
    }
}
