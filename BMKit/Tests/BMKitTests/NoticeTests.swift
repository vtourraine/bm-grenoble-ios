//
//  NoticeTests.swift
//  BMKitTests
//
//  Created by Vincent Tourraine on 12/03/2021.
//

import XCTest
@testable import BMKit

final class NoticeTests: XCTestCase {

    func testParseResponse() throws {
        let response = try decodeJSON(NoticeResponse.self, from: "get-notice-response-body.json")

        XCTAssertEqual(response.notices.count, 4)

        let notice = try XCTUnwrap(response.notices.first)
        XCTAssertEqual(notice.branch, "Centre Ville")
        XCTAssertEqual(notice.status, "Loaned")
    }
}
