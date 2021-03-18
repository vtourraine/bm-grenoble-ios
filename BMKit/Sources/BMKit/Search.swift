//
//  Search.swift
//  BMKit
//
//  Created by Vincent Tourraine on 08/03/2021.
//

import Foundation

extension URLRequest {
    struct Parameters: Encodable {
        let identifier: String
        let query: [String]?
        let pageSize: Int
        let pageIndex: Int?
        let locale: String

        private enum CodingKeys: String, CodingKey {
            case identifier = "queryid"
            case query
            case pageSize
            case pageIndex = "pageNo"
            case locale
        }
    }

    internal static func searchRequest(query: String, token: String, pageSize: Int, pageIndex: Int) -> URLRequest {
        let parameters = Parameters(identifier: "NONE", query: [query], pageSize: pageSize, pageIndex: pageIndex, locale: "en")
        return URLRequest(post: "search", token: token, jsonParameters: parameters)
    }
}

public let DefaultPageSize: Int = 10

extension URLSession {

    public func search(for query: String, with token: String, pageSize: Int = DefaultPageSize, pageIndex: Int = 1, completion: @escaping (Result<DocumentResponse, Error>) -> Void) -> URLSessionTask {
        let request = URLRequest.searchRequest(query: query, token: token, pageSize: pageSize, pageIndex: pageIndex)
        return fetch(DocumentResponse.self, request: request, completion: completion)
    }
}
