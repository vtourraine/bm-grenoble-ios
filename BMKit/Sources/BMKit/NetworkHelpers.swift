//
//  NetworkHelpers.swift
//  BMKit
//
//  Created by Vincent Tourraine on 13/03/2020.
//

import Foundation

let BaseURL = URL(string: "https://catalogue.bm-grenoble.fr")!

public enum NetworkError: Error {
    case unauthorized
    case unknown
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return NSLocalizedString("Invalid subscriber number or password", comment: "")
        case .unknown:
            return nil
        }
    }
}

extension URLRequest {
    init(endpoint: String, credentials: Credentials, parameters: [String: String]? = nil) {
        let url = BaseURL.appendingPathComponent("in/rest/api").appendingPathComponent(endpoint)

        if let parameters = parameters {
            let string = parameters.map { key, value in
                return "\(key)=\(value)"
            }.joined(separator: "&")

            self.init(url: url)
            httpMethod = "POST"
            httpBody = string.data(using: .utf8)
            allHTTPHeaderFields = ["Content-Type": "application/x-www-form-urlencoded",
                                   "Authorization": "Bearer \(credentials.token)",
                                   "Content-Length": String(string.count),
                                   "X-InMedia-Authorization": "Bearer \(credentials.token) \(credentials.settingsToken)"]
        }
        else {
            let url = BaseURL.appendingPathComponent("in/rest/api").appendingPathComponent(endpoint)

            self.init(url: url)

            httpMethod = "GET"
            allHTTPHeaderFields = ["Content-Type": "application/json",
                                   "Authorization": "Bearer \(credentials.token)"]
        }

    }
}

extension URLSession {
    func fetch<T>(_ type: T.Type, request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask where T : Decodable {
        let task = dataTask(with: request) { data, response, error in
            /*
             // Save to file for debug
             if #available(iOS 10.0, *) {
                 let path = FileManager.default.temporaryDirectory.appendingPathComponent("data.json")
                 try? data!.write(to: path)
                 print("Save to: \(path)")
             }
             */

            let decoder = JSONDecoder()
            guard error == nil, let data = data, let object = try? decoder.decode(T.self, from: data) else {
                let completionError = URLSession.networkError(with: error, response: response)
                DispatchQueue.main.async {
                    completion(.failure(completionError))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(object))
            }
        }
        
        task.resume()
        return task
    }

    internal static func networkError(with error: Error?, response: URLResponse?) -> Error {
        if let response = response as? HTTPURLResponse, response.statusCode == 401 {
            return NetworkError.unauthorized
        }
        else if let error = error {
            return error
        }
        else {
            return NetworkError.unknown
        }
    }
}
