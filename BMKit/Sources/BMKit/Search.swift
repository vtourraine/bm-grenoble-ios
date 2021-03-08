//
//  Search.swift
//  BMKit
//
//  Created by Vincent Tourraine on 08/03/2021.
//

import Foundation

extension URLRequest {
    internal static func searchRequest(for query: String, with token: String) -> URLRequest {
        struct Parameters: Encodable {
            let query: [String]
            let queryIdentifier: String

            private enum CodingKeys: String, CodingKey {
                case query
                case queryIdentifier = "queryid"
            }
        }

        let parameters = Parameters(query: [query], queryIdentifier: "NONE")
        return URLRequest(post: "search", token: token, jsonParameters: parameters)
    }
}

extension URLSession {
    public func search(for query: String, with token: String, completion: @escaping (Result<[Document], Error>) -> Void) -> URLSessionTask {
        let request = URLRequest.searchRequest(for: query, with: token)

        return fetch(DocumentResponse.self, request: request) { result in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
