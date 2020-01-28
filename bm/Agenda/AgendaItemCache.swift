//
//  AgendaItemCache.swift
//  bm
//
//  Created by Vincent Tourraine on 28/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import Foundation

struct AgendaItemCache: Codable {
    let items: [AgendaItem]

    static let Key = "AgendaItemsCache"

    static func save(items: [AgendaItem], to userDefaults: UserDefaults) {
        let cache = AgendaItemCache(items: items)
        let data = try? JSONEncoder().encode(cache)
        userDefaults.set(data, forKey: AgendaItemCache.Key)
    }

    static func load(from userDefaults: UserDefaults) -> AgendaItemCache? {
        guard let encodedData = userDefaults.data(forKey: AgendaItemCache.Key) else {
            return nil
        }

        return try! JSONDecoder().decode(AgendaItemCache.self, from: encodedData)
    }

    static func remove(from userDefaults: UserDefaults) {
        userDefaults.removeObject(forKey: AgendaItemCache.Key)
    }
}
