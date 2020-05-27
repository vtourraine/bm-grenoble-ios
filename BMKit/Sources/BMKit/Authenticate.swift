//
//  Authenticate.swift
//  BMKit
//
//  Created by Vincent Tourraine on 11/03/2020.
//

import Foundation

public class Authenticate {
    public static func authenticate(username: String, password: String, completion: @escaping (Result<Credentials, Error>) -> Void) -> URLSessionTask {
        let json = ["username": username, "password": password, "birthdate": "", "locale":"en"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        let url = URL(string: "https://catalogue-test.bm-grenoble.fr/in/rest/api/authenticate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]

        return URLSession.shared.fetch(Credentials.self, request: request, completion: completion)
    }
}
