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

extension URLSession {
    public func fetchAccountSummary(with session: Session, completion: @escaping (Result<AccountSummary, Error>) -> Void) -> URLSessionTask {
        let request = URLRequest(get: "accountSummary", session: session)
        return fetch(AccountSummary.self, request: request, completion: completion)
    }
}
