//
//  PageParser.swift
//  bm
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import Foundation

class PageParser {
    struct Pagination {
        let numberOfPages: Int
        let currentPage: Int
        let nextPage: URL?
    }

    class func parseLoans(html: String) -> (items: [Item], pagination: Pagination)? {
        guard let ul = html.parse(between: "<ul class=\"listItems\">", and: "</ul>"),
            let pagination = parsePagination(html: html) else {
                return nil
        }
        let lis = ul.parseOccurences(between: "<li", and: "</li>")
        let items: [Item] = lis.compactMap({ li in
            guard let titleLink = li.parse(between: "<span class=\"colValue bold\"><a", and: "/a>"),
                let title = titleLink.parse(between: "\">", and: " /"),
                let author = titleLink.parse(between: " /", and: "<")?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                let returnDate = li.parse(between: "<span style=\"font-weight:bold\">", and: "</span>"),
                let library = li.parse(between: "Emprunté à</span></td>\n<td><span class=\"colValue\">", and: "</span>") else {
                    return nil
            }

            let returnDateRawComponents = returnDate.components(separatedBy: "/")
            var returnDateComponents = DateComponents()
            if (returnDateRawComponents.count == 3) {
                returnDateComponents.day = Int(returnDateRawComponents[0])
                returnDateComponents.month = Int(returnDateRawComponents[1])
                returnDateComponents.year = Int(returnDateRawComponents[2])
            }

            return Item(title: title.cleanHTMLEntities(), author: author, library: library, returnDateComponents: returnDateComponents)
        })

        return (items, pagination)
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

extension String {

    func parseOccurences(between prefix: String, and suffix: String) -> [String] {
        var occurences: [String] = []
        var searchRange = self.startIndex ..< self.endIndex

        while true {
            let rangePrefix = self.range(of: prefix, options: [], range: searchRange)
            let startIndexOptional = rangePrefix?.upperBound

            guard let startIndex = startIndexOptional else {
                return occurences
            }

            let rangeSuffix = self.range(of: suffix, options: [], range: startIndex ..< self.endIndex)
            let endIndex = rangeSuffix?.lowerBound

            if let endIndex = endIndex {
                occurences.append(String(self[startIndex ..< endIndex]))
                searchRange = endIndex ..< self.endIndex
            }
            else {
                return occurences
            }
        }

        return occurences
    }

    func parse(between prefix: String, and suffix: String) -> String? {
        let rangePrefix = self.range(of: prefix)
        let startIndexOptional = rangePrefix?.upperBound

        guard let startIndex = startIndexOptional else {
            return nil
        }

        let rangeSuffix = self.range(of: suffix, options: [], range: startIndex ..< self.endIndex)
        let endIndex = rangeSuffix?.lowerBound

        if let endIndex = endIndex {
            return String(self[startIndex ..< endIndex])
        }
        else {
            return nil
        }
    }

    func parse(startingWith prefix: String, before suffix: String) -> String? {
        let startRange = self.range(of: prefix, options: [.caseInsensitive], range: nil, locale: nil)
        if let startRange = startRange {
            let endRange = self.range(of: suffix, options: [.caseInsensitive], range: startRange.lowerBound ..< self.endIndex, locale: nil)

            if let endRange = endRange {
                return String(self[startRange.lowerBound ..< endRange.lowerBound])
            }
            else {
                return String(self[startRange.lowerBound...])
            }
        }
        else {
            return nil
        }
    }

    func cleanHTMLEntities() -> String {
        return replacingOccurrences(of: "&amp;", with: "&")
    }
}
