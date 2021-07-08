//
//  NetworkHelpers.swift
//  BMKit
//
//  Created by Vincent Tourraine on 13/03/2020.
//

import Foundation

public let BaseURL = URL(string: "https://catalogue.bm-grenoble.fr")!

extension URLRequest {
    init(get endpoint: String, credentials: Credentials) {
        let url = BaseURL.appendingPathComponent("in/rest/api").appendingPathComponent(endpoint)
        self.init(url: url)

        httpMethod = "GET"
        allHTTPHeaderFields = ["Content-Type": "application/json",
                               "Authorization": "Bearer \(credentials.token)"]
    }

    init?(get endpoint: String, token: String, urlParameters parameters: [String: String]) {
        let url = BaseURL.appendingPathComponent("in/rest/api").appendingPathComponent(endpoint)
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        urlComponents.queryItems = parameters.map({ URLQueryItem(name: $0, value: $1)})
        guard let urlWithParamters = urlComponents.url else {
            return nil
        }

        self.init(url: urlWithParamters)

        httpMethod = "GET"
        allHTTPHeaderFields = ["Content-Type": "application/json",
                               "Authorization": "Bearer \(token)"]
    }

    init(post endpoint: String, credentials: Credentials, formEncodedParameters parameters: [String: String]) {
        let url = BaseURL.appendingPathComponent("in/rest/api").appendingPathComponent(endpoint)
        self.init(url: url)

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

    init<T: Encodable>(post endpoint: String, token: String, jsonParameters parameters: T) {
        let url = BaseURL.appendingPathComponent("in/rest/api").appendingPathComponent(endpoint)
        self.init(url: url)

        let bodyData = try? JSONEncoder().encode(parameters)

        httpMethod = "POST"
        httpBody = bodyData
        allHTTPHeaderFields = ["Content-Type": "application/json",
                               "X-InMedia-Authorization": "Bearer \(token)"]
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
                  (httpResponse.statusCode != 401 && httpResponse.statusCode != 403) else {
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
                try? data.write(to: path)
                print("Request: \(request.url!.absoluteString)")
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
