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

        private enum CodingKeys: String, CodingKey {
            case identifier = "queryid"
            case query
            case pageSize
            case pageIndex = "pageNo"
        }
    }

    internal static func searchRequest(identifier:String, token: String, pageSize: Int, pageIndex: Int) -> URLRequest {
        let parameters = Parameters(identifier: identifier, query: nil, pageSize: pageSize, pageIndex: pageIndex)
        return URLRequest(post: "search", token: token, jsonParameters: parameters)
    }

    internal static func searchRequest(identifier:String, query: String, token: String, pageSize: Int) -> URLRequest {
        let parameters = Parameters(identifier: "NONE", query: [query], pageSize: pageSize, pageIndex: nil)
        return URLRequest(post: "search", token: token, jsonParameters: parameters)
    }
}

public let DefaultPageSize: Int = 10

extension URLSession {

    public func search(for query: String, with token: String, identifier: String, pageSize: Int = DefaultPageSize, completion: @escaping (Result<DocumentResponse, Error>) -> Void) -> URLSessionTask {
        let request = URLRequest.searchRequest(identifier: identifier, query: query, token: token, pageSize: pageSize)
        return fetch(DocumentResponse.self, request: request, completion: completion)
    }

    public func search(with token: String, identifier: String, pageIndex: Int, pageSize: Int = DefaultPageSize, completion: @escaping (Result<DocumentResponse, Error>) -> Void) -> URLSessionTask {
        let request = URLRequest.searchRequest(identifier: identifier, token: token, pageSize: pageSize, pageIndex: pageIndex)
        return fetch(DocumentResponse.self, request: request, completion: completion)
    }
}
