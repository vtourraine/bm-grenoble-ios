//
//  Book.swift
//  bm
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019-2021 Studio AMANgA. All rights reserved.
//

import Foundation
import BMKit

struct Item: Codable {
    let title: String
    let author: String
    let library: String
    let returnDateComponents: DateComponents
    let image: URL?
}

extension Item {
    static func fetch(with credentials: Credentials, completion: @escaping (Result<[Item], Error>) -> Void) {
        _ = LoanItem.fetch(with: credentials) { result in
            switch result {
            case .success(let loanItems):
                let sequenceNumbers = loanItems.map { $0.sequenceNumber }
                _ = Document.fetch(sequenceNumbers, with: credentials) { resultFetchDocuments in
                    switch resultFetchDocuments {
                    case .success(let documents):
                        let items = Item.items(with: loanItems, and: documents)
                        completion(.success(items))

                    case .failure(let fetchDocumentsError):
                        completion(.failure(fetchDocumentsError))
                    }
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    static func items(with loanItems: [LoanItem], and documents: [Document]) -> [Item] {
        guard loanItems.count == documents.count else {
            return []
        }

        var items = [Item]()

        for loanItem in loanItems {
            guard let document = documents.first(where: { $0.localNumber.hasSuffix(loanItem.sequenceNumber) }) else {
                continue
            }

            let item = Item(title: loanItem.title ?? "", author: loanItem.author ?? "", library: loanItem.library, returnDateComponents: loanItem.returnDateComponents, image: document.imageURL)
            items.append(item)
        }

        return items
    }

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
