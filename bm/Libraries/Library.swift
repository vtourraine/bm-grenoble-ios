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

import CoreLocation

struct Library: Codable {
    let name: String
    let openingTime: String
    let webpage: String
    let address: String = "10 Rue de la République\n38000 Grenoble"
    let phoneNumber: String = "04 76 54 57 97"
    let mailAddress: String = "bm.internationale@bm-grenoble.fr"
    let accessibility: Bool = true

    let latitude: Double
    let longitude: Double
}

extension Library {
    func location() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
