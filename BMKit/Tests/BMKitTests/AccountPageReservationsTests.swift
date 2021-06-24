//
//  AccountPageReservationsTests.swift
//  
//
//  Created by Vincent Tourraine on 24/06/2021.
//

import XCTest
@testable import BMKit

final class AccountPageReservationsTests: XCTestCase {
    func testParseResponse() throws {
        let accountPage = try decodeJSON(AccountPage.self, from: "get-accountpage-reservations-response-body.json")
        XCTAssertEqual(accountPage.items.count, 1)
        XCTAssertEqual(accountPage.items[0].data.title, "Jimmy Corrigan or the smartest kid on earth / Chris Ware")
        XCTAssertEqual(accountPage.items[0].data.statusDescription, "Le document sera bientôt disponible")
    }
}
