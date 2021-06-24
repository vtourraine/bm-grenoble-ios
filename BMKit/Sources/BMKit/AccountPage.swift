//
//  AccountPage.swift
//  
//
//  Created by Vincent Tourraine on 24/06/2021.
//

import Foundation

public struct AccountPage: Codable {
    let items: [AccountPageItem]
}

public struct AccountPageItem: Codable {
    let data: Data

    public struct Data: Codable {
        public let title: String
        public let statusDescription: String
    }
}

extension URLSession {
    public func fetchAccountPageReservation(with credentials: Credentials, completion: @escaping (Result<AccountPage, Error>) -> Void) -> URLSessionTask {
        // accountPage?type=reservations&pageNo=1&pageSize=10&locale=en&_=1624534015042
        let request = URLRequest(get: "accountPage", token: credentials.token, urlParameters: ["type": "reservations", "pageNo": "1", "pageSize": "10", "locale": "en"])!
        return fetch(AccountPage.self, request: request, completion: completion)
    }
}
