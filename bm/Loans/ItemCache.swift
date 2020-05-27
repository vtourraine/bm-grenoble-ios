//
//  ItemCache.swift
//  bm
//
//  Created by Vincent Tourraine on 01/08/2019.
//  Copyright © 2019-2020 Studio AMANgA. All rights reserved.
//

import Foundation
import BMKit

struct ItemCache: Codable {
    let items: [LoanItem]

    static let Key = "ItemsCache"

    static func save(items: ItemCache, to userDefaults: UserDefaults) {
        let data = try? JSONEncoder().encode(items)
        userDefaults.set(data, forKey: ItemCache.Key)
    }

    static func load(from userDefaults: UserDefaults) -> ItemCache? {
        guard let encodedData = userDefaults.data(forKey: ItemCache.Key),
            let objects = try? JSONDecoder().decode(ItemCache.self, from: encodedData) else {
            return nil
        }

        return objects
    }

    static func remove(from userDefaults: UserDefaults) {
        userDefaults.removeObject(forKey: ItemCache.Key)
    }
}
