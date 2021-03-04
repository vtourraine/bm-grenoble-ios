//
//  Authenticate.swift
//  BMKit
//
//  Created by Vincent Tourraine on 11/03/2020.
//

import Foundation

public struct AuthenticationResponse: Codable {
    public let token: String
    public let userIdentifier: String

    private enum CodingKeys: String, CodingKey {
        case token
        case userIdentifier = "userid"
    }
}

extension URLSession {
    public func connect(username: String, password: String, completion: @escaping (Result<Credentials, Error>) -> Void) {
        _ = authenticate(username: username, password: password) { authenticationResult in
            switch authenticationResult {
            case .success(let authenticationResponse):
                _ = self.fetchSettings() { fetchSettingsResult in
                    switch fetchSettingsResult {
                    case .success(let settingsAPIToken):
                        let credentials = Credentials(token: authenticationResponse.token, settingsToken: settingsAPIToken, userIdentifier: authenticationResponse.userIdentifier)
                        completion(.success(credentials))

                    case .failure(let error):
                        completion(.failure(error))
                    }
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func authenticate(username: String, password: String, completion: @escaping (Result<AuthenticationResponse, Error>) -> Void) -> URLSessionTask {
        let json = ["username": username, "password": password, "birthdate": "", "locale":"en"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        let url = URL(string: "https://catalogue.bm-grenoble.fr/in/rest/api/authenticate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]

        return fetch(AuthenticationResponse.self, request: request, completion: completion)
    }
}
