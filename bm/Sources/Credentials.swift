//
//  Credentials.swift
//  bm
//
//  Created by Vincent Tourraine on 02/08/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import Foundation

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
}

