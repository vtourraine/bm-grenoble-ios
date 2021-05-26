//
//  Credentials+KeychainAccess.swift
//  BM Grenoble
//
//  Created by Vincent Tourraine on 05/03/2021.
//  Copyright © 2021 Studio AMANgA. All rights reserved.
//

import Foundation
import BMKit
import KeychainAccess

extension Credentials {
    static let Key = "Credentials"

    func save(to keychain: Keychain) {
        guard let data = try? JSONEncoder().encode(self) else {
            return
        }

        try? keychain.set(data, key: Credentials.Key)
    }

    static func load(from keychain: Keychain) -> Credentials? {
        guard let encodedData = try? keychain.getData(Credentials.Key) else {
            return nil
        }

        let credentials = try? JSONDecoder().decode(Credentials.self, from: encodedData)
        return credentials
    }

    static func remove(from keychain: Keychain) {
        try? keychain.remove(Credentials.Key)
    }
}

extension Credentials {
    static func defaultKeychain() -> Keychain {
        return Keychain(service: "com.studioamanga.bmg", accessGroup: "77S3V3W24J.com.studioamanga.bmg.shared").synchronizable(true)
    }

    static func sharedCredentials() -> Credentials? {
        return load(from: Credentials.defaultKeychain())
    }
}
