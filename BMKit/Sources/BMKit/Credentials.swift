//
//  Credentials.swift
//  BMKit
//
//  Created by Vincent Tourraine on 13/03/2020.
//

import Foundation
import KeychainAccess

public struct Credentials: Codable {
    public let token: String
    public let userIdentifier: String

    private enum CodingKeys: String, CodingKey {
        case token
        case userIdentifier = "userid"
    }
}

public extension Credentials {
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

    static func defaultKeychain() -> Keychain {
        return Keychain(service: "com.studioamanga.bmg", accessGroup: "77S3V3W24J.com.studioamanga.bmg.shared").synchronizable(true)
    }

    static func sharedCredentials() -> Credentials? {
        return load(from: Credentials.defaultKeychain())
    }
}
