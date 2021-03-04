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
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = dataTask(with: request) { data, response, error in
            guard error == nil, let data = data,
                  let apiToken = Settings.apiToken(from: data) else {
                let completionError = URLSession.networkError(with: error, response: response)
                DispatchQueue.main.async {
                    completion(.failure(completionError))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(apiToken))
            }
        }

        task.resume()
        return task
    }
}
