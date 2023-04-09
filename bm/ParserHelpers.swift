//
//  ParserHelpers.swift
//  bm
//
//  Created by Vincent Tourraine on 09/01/2020.
//  Copyright © 2020-2023 Studio AMANgA. All rights reserved.
//

import Foundation

extension String {

    func parseOccurences(between pairs: [(String, String)]) -> [String] {
        for pair in pairs {
            let result = parseOccurences(between: pair.0, and: pair.1)
            if !result.isEmpty {
                return result
            }
        }

        return []
    }

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

    func parse(between pairs: [(String, String)]) -> String? {
        for pair in pairs {
            if let result = parse(between: pair.0, and: pair.1) {
                return result
            }
        }

        return nil
    }

    func parse(between prefixes: [String], and suffix: String) -> String? {
        for prefix in prefixes {
            if let result = parse(between: prefix, and: suffix) {
                return result
            }
        }

        return nil
    }

    func parse(between prefix: String, and suffix: String) -> String? {
        let rangePrefix = range(of: prefix)

        guard let startIndex = rangePrefix?.upperBound else {
            return nil
        }

        let rangeSuffix = range(of: suffix, options: [], range: index(after: startIndex) ..< self.endIndex)
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

    func parse(after prefix: String) -> String? {
        guard let range = range(of: prefix) else {
            return nil
        }

        return String(self[range.upperBound...])
    }

    func parse(before suffix: String) -> String? {
        guard let range = range(of: suffix) else {
            return nil
        }

        return String(self[..<range.lowerBound])
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
