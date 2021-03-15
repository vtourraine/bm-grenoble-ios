//
//  Notice.swift
//  BMKit
//
//  Created by Vincent Tourraine on 12/03/2021.
//

import Foundation

public struct Notice: Codable {
    public let branch: String
    public let status: String

    private enum CodingKeys: String, CodingKey {
        case branch = "branch_desc"
        case status = "stat_desc"
    }

    private enum MiddleCodingKeys: String, CodingKey {
        case data
        case children
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: MiddleCodingKeys.self)
        let data = try values.decode([String:String].self, forKey: .data)
        let children = try values.decode([[String:[String:String]]].self, forKey: .children)
        branch = data[CodingKeys.branch.rawValue] ?? ""
        status = children.first!["data"]![CodingKeys.status.rawValue] ?? ""
    }
}

extension Notice {
    public enum Status {
        case available
        case notAvailable
    }

    public func availability() -> Status {
        if status == "Avalaible" {
            return .available
        }
        else {
            return .notAvailable
        }
    }
}

public struct NoticeResponse: Codable {
    let notices: [Notice]

    private enum CodingKeys: String, CodingKey {
        case notices = "monographicCopies"
    }
}

extension URLRequest {
    internal static func fetchNoticeRequest(_ identifier: String, with token: String) -> URLRequest {
        let parameters = ["locale": "en",
                          "id": identifier,
                          "aspect": "Stock",
                          "opac": "true"]
        return URLRequest(get: "notice", token: token, urlParameters: parameters)!
    }
}

extension URLSession {
    public func fetchNotice(_ identifier: String, with token: String, completion: @escaping (Result<[Notice], Error>) -> Void) -> URLSessionTask {
        let request = URLRequest.fetchNoticeRequest(identifier, with: token)
        return fetch(NoticeResponse.self, request: request) { result in
            switch result {
            case .success(let response):
                completion(.success(response.notices))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
