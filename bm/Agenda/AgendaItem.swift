//
//  AgendaItem.swift
//  bm
//
//  Created by Vincent Tourraine on 11/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import Foundation

struct AgendaItem: Codable {
    enum AgendaDate {
        case day(DateComponents)
        case range(DateComponents, DateComponents)
    }

    let title: String
    let summary: String
    let category: String
    let library: String
    let link: URL
    let date: AgendaDate
    let image: URL?
}

extension AgendaItem.AgendaDate: Encodable, Decodable {
    enum CodingKeys: CodingKey {
        case day
        case rangeStart
        case rangeEnd
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .day(let value):
            try container.encode(value, forKey: .day)
        case .range(let startValue, let endValue):
            try container.encode(startValue, forKey: .rangeStart)
            try container.encode(endValue, forKey: .rangeEnd)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let dayValue =  try container.decode(DateComponents.self, forKey: .day)
            self = .day(dayValue)
        } catch {
            let rangeStartValue =  try container.decode(DateComponents.self, forKey: .rangeStart)
            let rangeEndValue =  try container.decode(DateComponents.self, forKey: .rangeEnd)
            self = .range(rangeStartValue, rangeEndValue)
        }
    }
}
