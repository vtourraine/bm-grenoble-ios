//
//  PageParser.swift
//  bm
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import Foundation

class PageParser {
    class func parseLoans(html: String) -> [Item] {
        guard let ul = html.parse(between: "<ul class=\"listItems\">", and: "</ul>") else {
            return []
        }
        let lis = ul.parseOccurences(between: "<li", and: "</li>")
        return lis.compactMap({ li in
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

            return Item(title: title, author: author, library: library, returnDateComponents: returnDateComponents)
        })
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
}
