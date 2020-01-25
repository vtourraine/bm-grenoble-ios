//
//  ParserHelpers.swift
//  bm
//
//  Created by Vincent Tourraine on 09/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import Foundation

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
        var string = self
        let entities = ["&amp;": "&",
                        "&#039;": "'",
                        "&quot;": "\""]

        for (key, value) in entities {
            string = string.replacingOccurrences(of: key, with: value)
        }

        return string
    }

    func cleanHTMLEntitiesAndTags() -> String {
        var string = self.cleanHTMLEntities()
        let tags = ["<br>", "\r"]

        for tag in tags {
            string = string.replacingOccurrences(of: tag, with: "")
        }

        return string
    }
}
