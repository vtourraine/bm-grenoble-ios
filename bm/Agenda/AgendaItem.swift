//
//  AgendaItem.swift
//  bm
//
//  Created by Vincent Tourraine on 11/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import Foundation

struct AgendaItem {
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
