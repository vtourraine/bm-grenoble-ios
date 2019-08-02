//
//  ItemCache.swift
//  bm
//
//  Created by Vincent Tourraine on 01/08/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import Foundation

struct ItemCache: Codable {
    let items: [Item]

    static let Key = "ItemsCache"

    static func save(items: ItemCache, to userDefaults: UserDefaults) {
        let data = try? JSONEncoder().encode(items)
        userDefaults.set(data, forKey: ItemCache.Key)
    }

    static func load(from userDefaults: UserDefaults) -> ItemCache? {
        guard let encodedData = userDefaults.data(forKey: ItemCache.Key) else {
            return nil
        }

        return try! JSONDecoder().decode(ItemCache.self, from: encodedData)
    }
}
