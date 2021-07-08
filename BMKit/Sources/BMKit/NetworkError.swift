//
//  NetworkError.swift
//  BMKit
//
//  Created by Vincent Tourraine on 05/03/2021.
//

import Foundation

public enum NetworkError: Error {
    case unauthorized
    case forbidden
    case invalidData
    case unknown
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return NSLocalizedString("Invalid subscriber number or password", comment: "")
        case .forbidden:
            return NSLocalizedString("Forbidden access. You might need to sign out and log in again.", comment: "")
        case .invalidData:
            return NSLocalizedString("Invalid data", comment: "")
        case .unknown:
            return nil
        }
    }
}

extension NetworkError {
    internal static func networkError(with error: Error?, response: URLResponse?) -> Error {
        if let response = response as? HTTPURLResponse, response.statusCode == 401 {
            return NetworkError.unauthorized
        }
        else if let response = response as? HTTPURLResponse, response.statusCode == 403 {
            return NetworkError.forbidden
        }
        else if let error = error {
            return error
        }
        else {
            return NetworkError.unknown
        }
    }
}
