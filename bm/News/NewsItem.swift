//
//  NewsItem.swift
//  bm
//
//  Created by Vincent Tourraine on 09/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import Foundation

struct NewsItem: Codable {
    let title: String
    let summary: String
    let link: URL
    let image: URL?
}
