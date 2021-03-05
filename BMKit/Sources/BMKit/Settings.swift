//
//  Settings.swift
//  BMKit
//
//  Created by Vincent Tourraine on 04/03/2021.
//

import Foundation

public class Settings {
    let data: Data

    public init(_ data: Data) {
        self.data = data
    }

    public func apiToken() -> String? {
        guard let string = String(data: data, encoding: .utf8),
              let before = string.range(of: "\"apiToken\":\""),
              let after = string.range(of: "\",\"chatAllowAttachmentUpload\"") else {
            return nil
        }

        return String(string[before.upperBound..<after.lowerBound])
    }

    public static func apiToken(from data: Data) -> String? {
        let settings = Settings(data)
        return settings.apiToken()
    }
}

extension URLSession {
    public func fetchSettings(completion: @escaping (Result<String, Error>) -> Void) -> URLSessionTask {
        let url = BaseURL.appendingPathComponent("account/in/rest/api/settings.js")
        let request = URLRequest(url: url)

        return fetchData(request: request) { result in
            switch result {
            case .success(let data):
                if let apiToken = Settings.apiToken(from: data) {
                    completion(.success(apiToken))
                }
                else {
                    completion(.failure(NetworkError.unknown))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
