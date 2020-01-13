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

    struct Pagination {
        let numberOfPages: Int
        let currentPage: Int
        let nextPage: URL?
    }

    class func parseLoans(html: String) -> (items: [Item], pagination: Pagination)? {
        if html.contains("<div class=\"accountEmptyList\">") && html.contains("<ul class=\"listItems\">") == false {
            let pagination = Pagination(numberOfPages: 0, currentPage: 0, nextPage: nil)
            return ([], pagination)
        }

        guard let ul = html.parse(between: "<ul class=\"listItems\">", and: "</ul>"),
            let pagination = parsePagination(html: html) else {
                return nil
        }
        let lis = ul.parseOccurences(between: "<li", and: "</li>")
        let items: [Item] = lis.compactMap({ li in
            return parseLoan(li: li)
        })

        return (items, pagination)
    }

    class func parseLoan(li: String) -> Item? {
        guard let titleLink = li.parse(between: "<span class=\"colValue bold\"><a", and: "/a>"),
            let title = titleLink.parse(between: "\">", and: " /"),
            let author = titleLink.parse(between: " /", and: "<")?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
            let returnDate = li.parse(between: "<span style=\"font-weight:bold\">", and: "</span>"),
            let library = li.parse(between: "Emprunté à</span></td>\n<td><span class=\"colValue\">", and: "</span>") else {
                return nil
        }

        let image: URL?
        if let imageString = li.parse(between: "<img src=\"", and: "\""),
            let imageURL = URL(string: "\(CatalogueRoot)\(imageString)") {
            image = imageURL
        }
        else {
            image = nil
        }

        let returnDateRawComponents = returnDate.components(separatedBy: "/")
        var returnDateComponents = DateComponents()
        if (returnDateRawComponents.count == 3) {
            returnDateComponents.day = Int(returnDateRawComponents[0])
            returnDateComponents.month = Int(returnDateRawComponents[1])
            returnDateComponents.year = Int(returnDateRawComponents[2])
        }

        return Item(title: title.cleanHTMLEntities(), author: author, library: library, returnDateComponents: returnDateComponents, image: image)
    }

    class func parsePagination(html: String) -> Pagination? {
        guard let pageIndexString = html.parse(between: "var currentPage = ", and: ";"),
            let pageIndex = Int(pageIndexString) else {
                return nil
        }

        let numberOfPages: Int
        let nextPage: URL?
        if let pagesLinks = html.parse(between: "<span class=\"yt-uix-pager\"", and: "</span>") {
            numberOfPages = (pagesLinks.components(separatedBy: "<a").count - 2)

            if let nextPageString = pagesLinks.parse(between: "\(numberOfPages)</a><a href=\"", and: "\" class=\"paginationNext\"") {
                nextPage = URL(string: nextPageString)
            }
            else {
                nextPage = nil
            }
        }
        else {
            numberOfPages = 1
            nextPage = nil
        }

        return Pagination(numberOfPages: numberOfPages, currentPage: (pageIndex - 1), nextPage: nextPage)
    }
}
