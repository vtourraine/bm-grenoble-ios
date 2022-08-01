//
//  AccountPage.swift
//  
//
//  Created by Vincent Tourraine on 24/06/2021.
//

import Foundation

public struct AccountPage: Codable {
    public let items: [AccountPageItem]
}

public struct AccountPageItem: Codable {
    public let data: Data

    public struct Data: Codable {
        public let title: String
        public let statusDescription: String
        public let branch: Branch
    }

    public struct Branch: Codable {
        public let name: String

        private enum CodingKeys: String, CodingKey {
            case name = "desc"
        }
    }
}

extension URLSession {
    public func fetchAccountPageReservation(with session: Session, completion: @escaping (Result<AccountPage, Error>) -> Void) -> URLSessionTask {
        let request = URLRequest(get: "accountPage", token: session.token, urlParameters: ["type": "reservations", "pageNo": "1", "pageSize": "10", "locale": "en"])!
        return fetch(AccountPage.self, request: request, completion: completion)
    }
}
