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
    static func fetchItems(with credentials: Credentials, completion: @escaping (Result<[Item], Error>) -> Void) {
        let urlSession = URLSession.shared

        _ = urlSession.fetchLoans(with: credentials) { result in
            switch result {
            case .success(let loanItems):
                let sequenceNumbers = loanItems.map { $0.sequenceNumber }
                _ = urlSession.fetchDocuments(sequenceNumbers, with: credentials) { resultFetchDocuments in
                    switch resultFetchDocuments {
                    case .success(let response):
                        let items = Item.items(with: loanItems, and: response.documents)
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

    static func items(with loanItems: [Loan], and documents: [Document]) -> [Item] {
        guard loanItems.count == documents.count else {
            return []
        }

        var items = [Item]()

        for loanItem in loanItems {
            guard let document = documents.first(where: { $0.localNumber.hasSuffix(loanItem.sequenceNumber) }) else {
                continue
            }

            let author: String
            if let firstCreator = document.meta?.creators?.first,
               let components = firstCreator.nameComponents() {
                author = PersonNameComponentsFormatter.localizedString(from: components, style: .default)
            }
            else {
                author = ""
            }

            let item = Item(title: document.formattedTitle(), type: document.type, author: author, library: loanItem.library, returnDateComponents: loanItem.returnDateComponents, image: document.imageURL)
            items.append(item)
        }

        return items
    }
}

extension Document {
    func formattedTitle() -> String {
        if let slash = title.range(of: " / ") {
            return String(title[..<slash.lowerBound])
        }
        
        return title
    }

    static func systemImageName(for type: String) -> String {
        switch type {
        case "DVD":
            return "tv"
        case "CD":
            return "smallcircle.circle"
        default:
            return "book"
        }
    }

    func systemImageNameForType() -> String {
        return Document.systemImageName(for: type)
    }
}
