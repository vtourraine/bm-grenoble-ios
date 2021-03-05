//
//  NetworkError.swift
//  BMKit
//
//  Created by Vincent Tourraine on 05/03/2021.
//

import Foundation

public enum NetworkError: Error {
    case unauthorized
    case invalidData
    case unknown
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return NSLocalizedString("Invalid subscriber number or password", comment: "")
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
        else if let error = error {
            return error
        }
        else {
            return NetworkError.unknown
        }
    }
}
