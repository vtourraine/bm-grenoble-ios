//
//  Book.swift
//  bm
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import Foundation

struct Item: Codable {
    let title: String
    let author: String
    let library: String
    let returnDateComponents: DateComponents
    let image: URL?
}

extension Item {
    enum Category {
        case book
        case dvd
        case bluray
        case game
    }

    func category() -> Category {
        let DVDPrefix = " [DVD]"
        let BDPrefix = " [BLU-RAY]"
        let gamePrefix = " [JEU]"

        if title.contains(DVDPrefix) {
            return .dvd
        }
        else if title.hasSuffix(BDPrefix) {
            return .bluray
        }
        else if title.hasSuffix(gamePrefix) {
            return .game
        }
        else {
            return .book
        }
    }

    func formattedTitle() -> String {
        let DVDPrefix = " [DVD]"
        let BDPrefix = " [BLU-RAY]"
        let gamePrefix = " [JEU]"
        let formattedTitle = title.replacingOccurrences(of: ": =", with: "–")

        return formattedTitle.replacingOccurrences(of: DVDPrefix, with: "").replacingOccurrences(of: BDPrefix, with: "").replacingOccurrences(of: gamePrefix, with: "")
    }

    func formattedAuthor() -> String {
        guard var firstAuthor = author.components(separatedBy: ";").first else {
            return author
        }

        let extras = ["texte de", ", réal.", "réalisé par", "scénario"]
        for extra in extras {
            firstAuthor = firstAuthor.replacingOccurrences(of: extra, with: "")
        }

        return firstAuthor.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
