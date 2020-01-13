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
    func formattedTitle() -> String {
        let DVDPrefix = " [DVD]"
        let BDPrefix = " [BLU-RAY]"
        let gamePrefix = " [JEU]"
        let formattedTitle = title.replacingOccurrences(of: ": =", with: "–")

        if formattedTitle.contains(DVDPrefix) {
            return "📀 ".appending(formattedTitle.replacingOccurrences(of: DVDPrefix, with: ""))
        }
        else if formattedTitle.hasSuffix(BDPrefix) {
            return "📀 ".appending(formattedTitle.replacingOccurrences(of: BDPrefix, with: ""))
        }
        else if formattedTitle.hasSuffix(gamePrefix) {
            return "🎲 ".appending(formattedTitle.replacingOccurrences(of: gamePrefix, with: ""))
        }
        else {
            return "📖 ".appending(formattedTitle)
        }
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
