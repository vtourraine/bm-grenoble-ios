//
//  LoansTests.swift
//  BMKitTests
//
//  Created by Vincent Tourraine on 13/03/2020.
//

import XCTest
@testable import BMKit

final class LoansTests: XCTestCase {
    func testParseResponse() throws {
        let loans = try decodeJSON([Loan].self, from: "get-loans-response-body.json")

        XCTAssertEqual(loans.count, 3)
        XCTAssertEqual(loans[0].title, "We need to talk about Kevin [DVD] / Lynne Ramsay, réal. ; Lionel Shriver, adapt. ; avec Ezra Miller, John C. Reilly, Tilda Swinton.")
        XCTAssertEqual(loans[0].author, "Ramsay, Lynne")
        XCTAssertEqual(loans[0].isbn, "")
        XCTAssertEqual(loans[0].library, "Bibliothèque municipale internationale")
        XCTAssertEqual(loans[0].returnDateComponents.day, 27)
        XCTAssertEqual(loans[0].returnDateComponents.month, 3)
        XCTAssertEqual(loans[0].returnDateComponents.year, 2020)
        
        XCTAssertEqual(loans[2].title, "Banana girl : jaune à l'extérieur, blanche à l'intérieur / Kei Lam")
        XCTAssertEqual(loans[2].author, "Lam, Kei (1985-....)")
        XCTAssertEqual(loans[2].isbn, "978-2-36846-108-2 17 EUR")
    }

    static var allTests = [
        ("testParseResponse", testParseResponse),
    ]
}
