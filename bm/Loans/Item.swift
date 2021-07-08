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
    let identifier: String
    let isRenewable: Bool
    let title: String
    let type: String
    let author: String
    let library: String
    let returnDateComponents: DateComponents
    let image: URL?
}

extension URLSession {
    func fetchItems(with credentials: Credentials, completion: @escaping (Result<[Item], Error>) -> Void) {
        _ = fetchLoans(with: credentials) { result in
            switch result {
            case .success(let loanItems):
                let sequenceNumbers = loanItems.map { $0.sequenceNumber }
                _ = self.fetchDocuments(sequenceNumbers, with: credentials) { resultFetchDocuments in
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
}

extension Item {
    static func items(with loanItems: [Loan], and documents: [Document]) -> [Item] {
        guard loanItems.count == documents.count else {
            return []
        }

        var items = [Item]()

        for loan in loanItems {
            guard let document = documents.first(where: { $0.localNumber.hasSuffix(loan.sequenceNumber) }) else {
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

            let item = Item(identifier: loan.identifier, isRenewable: loan.isRenewable, title: document.formattedTitle(), type: document.type, author: author, library: loan.library, returnDateComponents: loan.returnDateComponents, image: document.imageURL)
            items.append(item)
        }

        return items
    }
}

