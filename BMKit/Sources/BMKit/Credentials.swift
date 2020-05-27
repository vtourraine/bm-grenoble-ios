//
//  Credentials.swift
//  BMKit
//
//  Created by Vincent Tourraine on 13/03/2020.
//

import Foundation

public struct Credentials: Codable {
    public let token: String
    public let userIdentifier: String

    private enum CodingKeys: String, CodingKey {
        case token, userIdentifier = "userid"
    }
}

public extension Credentials {
    static let Key = "Credentials"

    func save(to userDefaults: UserDefaults) {
        let data = try? JSONEncoder().encode(self)
        userDefaults.set(data, forKey: Credentials.Key)
    }

    static func load(from userDefaults: UserDefaults) -> Credentials? {
        guard let encodedData = userDefaults.data(forKey: Credentials.Key) else {
            return nil
        }

        let credentials = try? JSONDecoder().decode(Credentials.self, from: encodedData)
        return credentials
    }

    static func remove(from userDefaults: UserDefaults) {
        userDefaults.removeObject(forKey: Credentials.Key)
    }
}

