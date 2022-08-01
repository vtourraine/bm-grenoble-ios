//
//  Session+KeychainAccess.swift
//  BM Grenoble
//
//  Created by Vincent Tourraine on 05/03/2021.
//  Copyright © 2021 Studio AMANgA. All rights reserved.
//

import Foundation
import BMKit
import KeychainAccess

extension Session {
    static let Key = "Credentials"

    func save(to keychain: Keychain) {
        guard let data = try? JSONEncoder().encode(self) else {
            return
        }

        try? keychain.set(data, key: Session.Key)
    }

    static func load(from keychain: Keychain) -> Session? {
        guard let encodedData = try? keychain.getData(Session.Key) else {
            return nil
        }

        let session = try? JSONDecoder().decode(Session.self, from: encodedData)
        return session
    }

    static func remove(from keychain: Keychain) {
        try? keychain.remove(Session.Key)
    }
}

extension Session {
    static func defaultKeychain() -> Keychain {
        return Keychain(service: "com.studioamanga.bmg", accessGroup: "77S3V3W24J.com.studioamanga.bmg.shared").synchronizable(true)
    }

    static func sharedSession() -> Session? {
        return load(from: Session.defaultKeychain())
    }
}
