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
    let type: String
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

            let item = Item(title: loanItem.title ?? "", type: document.type, author: loanItem.author ?? "", library: loanItem.library, returnDateComponents: loanItem.returnDateComponents, image: document.imageURL)
            items.append(item)
        }

        return items
    }

    enum Category {
        case book
        case cd
        case dvd
        case bluray
        case game
    }

    func category() -> Category {
        let cdType = "CD"

        if type == cdType {
            return .cd
        }
        else {
            return .book
        }
    }

    func formattedTitle() -> String {
        if let slash = title.range(of: " / ") {
            return String(title[..<slash.lowerBound])
        }
        
        return title
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
