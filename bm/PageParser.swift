//
//  PageParser.swift
//  bm
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import Foundation

class PageParser {
    private static let CatalogueRoot = "http://catalogue.bm-grenoble.fr"

    class func parseLoans(html: String) -> [Item]? {
        /*
         if html.contains("<div class=\"accountEmptyList\">") && html.contains("<ul class=\"listItems\">") == false {
            return []
        }
         */

        guard let ul = html.parse(between: "<div class=\"table-responsive desktop-transactions hidden-xs hidden-sm\">", and: "<h2>Liens utiles") else {
                return nil
        }

        let lis = ul.parseOccurences(between: [("<tr", "</tr>")])

        let items: [Item] = lis.compactMap { parseLoan(li: $0) }

        return items
    }

    class func parseLoan(li: String) -> Item? {
        let infos = li.parseOccurences(between: "<td data-v-2296324c=\"\" title=\"", and: "\" class=\"")
        guard !li.contains("thumbnail-header"), infos.count == 5 else {
            return nil
        }

        let titleLink = infos[0]
        let title: String
        let author: String

        if let titleFirst = titleLink.parse(before: " / "),
           let titleSecond = titleLink.parse(after: " / ") {
            title = titleFirst
            author = titleSecond.replacingOccurrences(of: "&amp;", with: "&")
        }
        else {
            title = titleLink
            author = ""
        }

        let returnDate = infos[3]
        let image: URL?

        if let imageString = li.parse(between: "src=\"", and: "\" alt="),
           let imageURL = URL(string: imageString) {
            image = imageURL
        }
        else {
            image = nil
        }

        let returnDateRawComponents = returnDate.trimmingCharacters(in: .whitespaces).components(separatedBy: "/")
        var returnDateComponents = DateComponents()
        if (returnDateRawComponents.count == 3) {
            returnDateComponents.day = Int(returnDateRawComponents[0])
            returnDateComponents.month = Int(returnDateRawComponents[1])
            returnDateComponents.year = Int(returnDateRawComponents[2])
        }

        return Item(identifier: "", isRenewable: false, title: title.cleanHTMLEntities(), type: "", author: author, library: "", returnDateComponents: returnDateComponents, image: image)
    }
}
