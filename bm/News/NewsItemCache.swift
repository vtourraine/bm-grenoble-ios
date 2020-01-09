//
//  NewsItemCache.swift
//  bm
//
//  Created by Vincent Tourraine on 09/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import Foundation

struct NewsItemCache: Codable {
    let items: [NewsItem]

    static let Key = "NewsItemsCache"

    static func save(items: [NewsItem], to userDefaults: UserDefaults) {
        let cache = NewsItemCache(items: items)
        let data = try? JSONEncoder().encode(cache)
        userDefaults.set(data, forKey: NewsItemCache.Key)
    }

    static func load(from userDefaults: UserDefaults) -> NewsItemCache? {
        guard let encodedData = userDefaults.data(forKey: NewsItemCache.Key) else {
            return nil
        }

        return try! JSONDecoder().decode(NewsItemCache.self, from: encodedData)
    }

    static func remove(from userDefaults: UserDefaults) {
        userDefaults.removeObject(forKey: NewsItemCache.Key)
    }
}
