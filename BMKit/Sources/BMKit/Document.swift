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

    private enum CodingKeys: String, CodingKey {
        case localNumber = "LocalNumber"
        case title
        case type = "zmatIndex"
        case imageURL = "imageSource_256"
    }

    struct Value: Codable {
        public let value: String
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
    }
}

struct DocumentResponse: Codable {
    let results: [Document]

    private enum CodingKeys: String, CodingKey {
        case results = "resultSet"
    }
}

extension Document {
    enum Parameters {
        enum Keys: String {
            case locale
            case ids
        }
    }

    public static func fetch(_ ids: [String], with credentials: Credentials, completion: @escaping (Result<[Document], Error>) -> Void) -> URLSessionTask {
        let parameters = [Parameters.Keys.locale.rawValue: "en",
                          Parameters.Keys.ids.rawValue: ids.joined(separator: ",")]
        let request = URLRequest(endpoint: "resolveBySeqNo", credentials: credentials, parameters: parameters)

        return URLSession.shared.fetch(DocumentResponse.self, request: request) { (result) in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
