//
//  StockAvailabilityTests.swift
//  BMKitTests
//
//  Created by Vincent Tourraine on 08/03/2021.
//

import XCTest
@testable import BMKit

final class StockAvailabilityTests: XCTestCase {
    func testParseResponse() throws {
        let response = try decodeJSON(StockAvailabilityResponse.self, from: "get-stockavailabilityfor-response-body.json")
        XCTAssertEqual(response.count, 7)
    }
}
