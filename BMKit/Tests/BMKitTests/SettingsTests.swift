//
//  SettingsTests.swift
//  BMKitTests
//
//  Created by Vincent Tourraine on 04/03/2021.
//

import XCTest
@testable import BMKit

class SettingsTests: XCTestCase {

    func testParseAPIToken() throws {
        let settingsData = try XCTUnwrap(data(filename: "get-settings-response-body.js"))
        let apiToken = Settings.apiToken(from: settingsData)
        XCTAssertEqual(apiToken, "12346239-21a2-4e1b-98ac-c553d8357eb9")
    }
}
