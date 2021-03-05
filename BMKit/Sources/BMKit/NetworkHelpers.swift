//
//  NetworkHelpers.swift
//  BMKit
//
//  Created by Vincent Tourraine on 13/03/2020.
//

import Foundation

let BaseURL = URL(string: "https://catalogue.bm-grenoble.fr")!

extension URLRequest {
    init(endpoint: String, credentials: Credentials, parameters: [String: String]? = nil) {
        let url = BaseURL.appendingPathComponent("in/rest/api").appendingPathComponent(endpoint)
        self.init(url: url)

        if let parameters = parameters {
            let string = parameters.map { key, value in
                return "\(key)=\(value)"
            }.joined(separator: "&")

            httpMethod = "POST"
            httpBody = string.data(using: .utf8)
            allHTTPHeaderFields = ["Content-Type": "application/x-www-form-urlencoded",
                                   "Authorization": "Bearer \(credentials.token)",
                                   "Content-Length": String(string.count),
                                   "X-InMedia-Authorization": "Bearer \(credentials.token) \(credentials.settingsToken)"]
        }
        else {
            httpMethod = "GET"
            allHTTPHeaderFields = ["Content-Type": "application/json",
                                   "Authorization": "Bearer \(credentials.token)"]
        }
    }
}

extension URLSession {
    func fetch<T>(_ type: T.Type, request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask where T : Decodable {
        return fetchData(request: request) { result in
            switch result {
            case .success(let data):
                if let object = try? JSONDecoder().decode(T.self, from: data) {
                    completion(.success(object))
                }
                else {
                    completion(.failure(NetworkError.invalidData))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func fetchData(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            guard error == nil,
                  let data = data,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode != 401 else {
                let completionError = NetworkError.networkError(with: error, response: response)
                DispatchQueue.main.async {
                    completion(.failure(completionError))
                }
                return
            }

            /*
             // Save to file for debug
             if #available(iOS 10.0, *) {
                 let path = FileManager.default.temporaryDirectory.appendingPathComponent("data.json")
                 try? data!.write(to: path)
                 print("Save to: \(path)")
             }
             */

            DispatchQueue.main.async {
                completion(.success(data))
            }
        }

        task.resume()

        return task
    }
}
