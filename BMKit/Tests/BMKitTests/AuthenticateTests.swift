//
//  AuthenticateTests.swift
//  BMKitTests
//
//  Created by Vincent Tourraine on 13/03/2020.
//

import XCTest
@testable import BMKit

final class AuthenticateTests: XCTestCase {
    func testParseResponse() throws {
        let credentials = try decodeJSON(Credentials.self, from: "post-authenticate-response-body.json")
        XCTAssertEqual(credentials.token, "5dbb2956-6417-40ab-ad9c-910f6670eccc")
        XCTAssertEqual(credentials.userIdentifier, "0010001234359")
    }

    static var allTests = [
        ("testParseResponse", testParseResponse),
    ]
}
