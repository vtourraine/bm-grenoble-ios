//
//  Loan.swift
//  BMKit
//
//  Created by Vincent Tourraine on 13/03/2020.
//

import Foundation

public struct Loan: Codable {
    public let identifier: String
    public let isRenewable: Bool
    public let title: String?
    public let author: String?
    public let isbn: String?
    public let library: String
    public let returnDateComponents: DateComponents
    public let sequenceNumber: String

    private enum CodingKeys: String, CodingKey {
        case identifier = "documentNumber"
        case isRenewable
        case title
        case author
        case isbn
        case returnDateComponents = "returnDate"
        case library = "branch"
        case sequenceNumber = "seqNo"
    }

    private enum LibraryCodingKeys: String, CodingKey {
        case branchCode, desc
    }

    internal static func dateComponents(from string: String) throws -> DateComponents {
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
        
        identifier = try values.decode(String.self, forKey: .identifier)
        isRenewable = try values.decode(Bool.self, forKey: .isRenewable)
        title = try values.decode(String.self, forKey: .title)
        author = try values.decode(String.self, forKey: .author)
        isbn = try values.decode(String.self, forKey: .isbn)
        sequenceNumber = try values.decode(String.self, forKey: .sequenceNumber)

        let returnDateString = try values.decode(String.self, forKey: .returnDateComponents)
        returnDateComponents = try Loan.dateComponents(from: returnDateString)

        let branch = try values.nestedContainer(keyedBy: LibraryCodingKeys.self, forKey: .library)
        library = try branch.decode(String.self, forKey: .desc)
    }
}

public struct RenewLoanResponse: Codable {
    public let extended: Bool
    public let newLoanDate: DateComponents
    public let newReturnDate: DateComponents

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        extended = try values.decode(Bool.self, forKey: .extended)

        let returnDateString = try values.decode(String.self, forKey: .newReturnDate)
        newReturnDate = try Loan.dateComponents(from: returnDateString)

        let loanDateString = try values.decode(String.self, forKey: .newLoanDate)
        newLoanDate = try Loan.dateComponents(from: loanDateString)
    }
}

extension URLSession {
    public func fetchLoans(with credentials: Credentials, completion: @escaping (Result<[Loan], Error>) -> Void) -> URLSessionTask {
        let request = URLRequest(get: "loans", credentials: credentials)
        return fetch([Loan].self, request: request, completion: completion)
    }

    public func renew(_ loanIdentifier: String, with credentials: Credentials, completion: @escaping (Result<RenewLoanResponse, Error>) -> Void) -> URLSessionTask {
        let request = URLRequest(get: "renewLoan", token: credentials.token, urlParameters: ["documentId": loanIdentifier])!
        return fetch(RenewLoanResponse.self, request: request, completion: completion)
    }
}
