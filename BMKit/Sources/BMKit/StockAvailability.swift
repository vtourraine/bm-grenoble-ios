//
//  StockAvailability.swift
//  BMKit
//
//  Created by Vincent Tourraine on 08/03/2021.
//

import Foundation

public struct StockAvailability: Codable {
    public let canReserve: Bool
    public let hasCopies: Bool
    public let identifier: String
    public let isAvailable: Bool

    private enum CodingKeys: String, CodingKey {
        case canReserve
        case hasCopies
        case identifier = "id"
        case isAvailable
    }
}

public typealias StockAvailabilityResponse = [String: StockAvailability]

extension URLSession {
     public func stockAvailability(for documentIdentifiers: [String], with token: String, completion: @escaping (Result<StockAvailabilityResponse, Error>) -> Void) -> URLSessionTask {
        let parameters = ["iids": documentIdentifiers.joined(separator: ",")]
        let request = URLRequest(get: "stockAvailabilityFor", token: token, urlParameters: parameters)!

        return fetch(StockAvailabilityResponse.self, request: request, completion: completion)
     }
}
