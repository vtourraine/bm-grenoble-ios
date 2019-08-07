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
}

extension Item {
    func formattedTitle() -> String {
        let DVDPrefix = " [DVD]"
        if title.hasSuffix(DVDPrefix) {
            return "📀 ".appending(title.replacingOccurrences(of: DVDPrefix, with: ""))
        }
        else {
            return "📖 ".appending(title)
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
