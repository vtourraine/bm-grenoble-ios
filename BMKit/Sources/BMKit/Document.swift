//
//  Document.swift
//  BMKit
//
//  Created by Vincent Tourraine on 04/03/2021.
//

import Foundation

public struct Document: Codable {
    public let localNumber: String
    public let title: String
    public let type: String
    public let imageURL: URL?
    public let meta: Meta

    private enum CodingKeys: String, CodingKey {
        case localNumber = "LocalNumber"
        case title
        case type = "zmatIndex"
        case imageURL = "imageSource_256"
        case meta
    }

    struct Value: Codable {
        public let value: String
    }

    public struct Meta: Codable {
        public let creators: [Creator]?

        private enum CodingKeys: String, CodingKey {
            case creators = "creator"
        }
    }

    public struct Creator: Codable {
        public let name: String

        private enum CodingKeys: String, CodingKey {
            case name = "value"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let value = try values.decode(String.self, forKey: .name)
            name = value
        }

        @available(iOS 10.0, *)
        public func nameComponents() -> PersonNameComponents? {
            return PersonNameComponentsFormatter().personNameComponents(from: name)
        }
    }

    public init(title: String, localNumber: String, type: String, meta: Meta, imageURL: URL? = nil) {
        self.title = title
        self.localNumber = localNumber
        self.type = type
        self.meta = meta
        self.imageURL = imageURL
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let localNumberContainer = try values.decode([Value].self, forKey: .localNumber)
        localNumber = localNumberContainer.first!.value

        let titleContainer = try values.decode([Value].self, forKey: .title)
        title = titleContainer.first!.value

        let typeContainer = try values.decode([Value].self, forKey: .type)
        type = typeContainer.first!.value

        let imageURLContainer = try values.decode([Value].self, forKey: .imageURL)
        if let firstValue = imageURLContainer.first {
            let string = BaseURL.absoluteString + firstValue.value
            imageURL = URL(string: string)
        }
        else {
            imageURL = nil
        }

        meta = try values.decode(Meta.self, forKey: .meta)
    }
}

struct DocumentResponse: Codable {
    let results: [Document]

    private enum CodingKeys: String, CodingKey {
        case results = "resultSet"
    }
}

extension URLRequest {
    internal static func fetchDocumentsRequest(_ ids: [String], with credentials: Credentials) -> URLRequest {
        let parameters = ["locale": "en",
                          "ids": ids.joined(separator: ",")]
        return URLRequest(post: "resolveBySeqNo", credentials: credentials, formEncodedParameters: parameters)
    }
}

extension URLSession {
    public func fetchDocuments(_ ids: [String], with credentials: Credentials, completion: @escaping (Result<[Document], Error>) -> Void) -> URLSessionTask {
        let request = URLRequest.fetchDocumentsRequest(ids, with: credentials)

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

