//
//  AccountSummaryTests.swift
//  BMKitTests
//
//  Created by Vincent Tourraine on 13/03/2020.
//

import XCTest
@testable import BMKit

final class AccountSummaryTests: XCTestCase {
    func testParseResponse() throws {
        let accountSummary = try decodeJSON(AccountSummary.self, from: "get-accountsummary-response-body.json")
        XCTAssertEqual(accountSummary.firstName, "JOHN")
        XCTAssertEqual(accountSummary.lastName, "DOE")
    }

    static var allTests = [
        ("testParseResponse", testParseResponse),
    ]
}
