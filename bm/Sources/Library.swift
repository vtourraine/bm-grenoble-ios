//
//  Library.swift
//  bm
//
//  Created by Vincent Tourraine on 30/09/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import Foundation

struct Libraries: Codable {
    let lastUpdate: Date
    let libraries: [Library]
}

extension Libraries {
    static func loadCityLibraries() -> Libraries? {
        if let librariesPath = Bundle.main.path(forResource: "Libraries", ofType: "plist"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: librariesPath)) {
            let decoder = PropertyListDecoder()
            let libraries = try? decoder.decode(Libraries.self, from: data)
            return libraries
        }

        return nil
    }
}

struct Library: Codable {
    let name: String
    let openingTime: String
    let webpage: String
}
