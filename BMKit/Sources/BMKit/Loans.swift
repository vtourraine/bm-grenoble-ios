//
//  Loans.swift
//  BMKit
//
//  Created by Vincent Tourraine on 13/03/2020.
//

import Foundation

public struct LoanItem: Codable {
    public let title: String?
    public let author: String?
    public let isbn: String?
    public let library: String
    public let returnDateComponents: DateComponents
    public let image: URL?

    private enum CodingKeys: String, CodingKey {
        case title, author, isbn, returnDateComponents = "returnDate", library = "branch"
    }

    private enum LibraryCodingKeys: String, CodingKey {
        case branchCode, desc
    }

    private static func dateComponents(from string: String) throws -> DateComponents {
        guard string.count == 8 else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: ""))
        }

        let year = Int(string.prefix(4))
        let month = Int(string.suffix(4).prefix(2))
        let day = Int(string.suffix(2))
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return dateComponents
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        author = try values.decode(String.self, forKey: .author)
        isbn = try values.decode(String.self, forKey: .isbn)

        let returnDateString = try values.decode(String.self, forKey: .returnDateComponents)
        returnDateComponents = try LoanItem.dateComponents(from: returnDateString)

        let branch = try values.nestedContainer(keyedBy: LibraryCodingKeys.self, forKey: .library)
        library = try branch.decode(String.self, forKey: .desc)

        image = nil
    }
}

extension LoanItem {
    public static func fetch(with credentials: Credentials, completion: @escaping (Result<[LoanItem], Error>) -> Void) -> URLSessionTask {
        let request = URLRequest(endpoint: "loans", credentials: credentials)
        return URLSession.shared.fetch([LoanItem].self, request: request, completion: completion)
    }
}

extension LoanItem {
    public enum Category {
        case book
        case dvd
        case bluray
        case game
        case unknown
    }

    public func category() -> Category {
        guard let title = title else {
            return .unknown
        }

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

    public func formattedTitle() -> String? {
        let DVDPrefix = " [DVD]"
        let BDPrefix = " [BLU-RAY]"
        let gamePrefix = " [JEU]"
        let formattedTitle = title?.replacingOccurrences(of: ": =", with: "–")

        return formattedTitle?.replacingOccurrences(of: DVDPrefix, with: "").replacingOccurrences(of: BDPrefix, with: "").replacingOccurrences(of: gamePrefix, with: "")
    }

    public func formattedAuthor() -> String? {
        guard var firstAuthor = author?.components(separatedBy: ";").first else {
            return author
        }

        let extras = ["texte de", ", réal.", "réalisé par", "scénario"]
        for extra in extras {
            firstAuthor = firstAuthor.replacingOccurrences(of: extra, with: "")
        }

        return firstAuthor.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
