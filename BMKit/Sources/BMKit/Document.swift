//
//  Document.swift
//  BMKit
//
//  Created by Vincent Tourraine on 04/03/2021.
//

import Foundation

public struct Document: Codable {
    public let identifier: String
    public let localNumber: String
    public let title: String
    public let type: String
    public let ark: String
    public let imageURL: URL?
    public let meta: Meta?

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case localNumber = "LocalNumber"
        case title
        case ark
        case type = "zmatDisplay"
        case imageURL = "imageSource_128"
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

    public init(identifier: String, title: String, localNumber: String, type: String, meta: Meta? = nil, imageURL: URL? = nil, ark: String = "") {
        self.identifier = identifier
        self.title = title
        self.localNumber = localNumber
        self.type = type
        self.meta = meta
        self.imageURL = imageURL
        self.ark = ark
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let localNumberContainer = try values.decode([Value].self, forKey: .localNumber)
        localNumber = localNumberContainer.first!.value

        let identifierContainer = try values.decode([Value].self, forKey: .identifier)
        identifier = identifierContainer.first!.value

        let titleContainer = try values.decode([Value].self, forKey: .title)
        title = titleContainer.first!.value

        let typeContainer = try values.decode([Value].self, forKey: .type)
        type = typeContainer.first!.value

        let arkContainer = try values.decode([Value].self, forKey: .ark)
        ark = arkContainer.first!.value

        let imageURLContainer = try values.decode([Value].self, forKey: .imageURL)
        if let firstValue = imageURLContainer.first {
            let string = BaseURL.absoluteString + firstValue.value
            imageURL = URL(string: string)
        }
        else {
            imageURL = nil
        }

        meta = try? values.decode(Meta.self, forKey: .meta)
    }
}

public struct DocumentResponse: Codable {
    public let documents: [Document]
    public let pagesCount: Int
    public let pageIndex: Int

    private enum CodingKeys: String, CodingKey {
        case documents = "resultSet"
        case pagesCount = "maxPageNo"
        case pageIndex = "pageNo"
    }
}

extension URLRequest {
    internal static func fetchDocumentsRequest(_ ids: [String], with session: Session) -> URLRequest {
        let parameters = ["locale": "en",
                          "ids": ids.joined(separator: ",")]
        return URLRequest(post: "resolveBySeqNo", session: session, formEncodedParameters: parameters)
    }
}

extension URLSession {
    public func fetchDocuments(_ ids: [String], with session: Session, completion: @escaping (Result<DocumentResponse, Error>) -> Void) -> URLSessionTask {
        let request = URLRequest.fetchDocumentsRequest(ids, with: session)
        return fetch(DocumentResponse.self, request: request, completion: completion)
    }
}

