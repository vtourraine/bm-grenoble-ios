//
//  AccountSummary.swift
//  BMKit
//  
//  Created by Vincent Tourraine on 11/03/2020.
//

import Foundation

public struct AccountSummary: Codable {
    let firstName: String?
    let lastName: String?
}

extension AccountSummary {
    public static func fetch(credentials: Credentials, completion: @escaping (Result<AccountSummary, Error>) -> Void) -> URLSessionTask {
        let request = URLRequest(endpoint: "accountSummary", credentials: credentials)
        return URLSession.shared.fetch(self, request: request, completion: completion)
    }
}
