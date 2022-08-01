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
        let session = try decodeJSON(AuthenticationResponse.self, from: "post-authenticate-response-body.json")
        XCTAssertEqual(session.token, "5dbb2956-6417-40ab-ad9c-910f6670eccc")
        XCTAssertEqual(session.userIdentifier, "0010001234359")
    }

    static var allTests = [
        ("testParseResponse", testParseResponse),
    ]
}
