//
//  LoansTests.swift
//  bmTests
//
//  Created by Vincent Tourraine on 04/03/2021.
//  Copyright © 2021 Studio AMANgA. All rights reserved.
//

import XCTest
@testable import BMKit
@testable import bm

class LoansTest: XCTestCase {

    private func loadLoans(fromFileNamed fileName: String) throws -> [Item] {
        let path = try XCTUnwrap(Bundle(for: type(of: self)).path(forResource: fileName, ofType: "html"))
        let html = try XCTUnwrap(String(contentsOfFile: path))
        let loans = try XCTUnwrap(PageParser.parseLoans(html: html))
        return loans
    }

    func testParseLoans1() throws {
        let loans = try loadLoans(fromFileNamed: "TestLoans-2024-1")

        XCTAssertEqual(loans.count, 13)

        let item = try XCTUnwrap(loans.first)
        XCTAssertEqual(item.title, "Les Mythics. 19,, Hypérion")
        XCTAssertEqual(item.author, "scénario Philippe Ogaki")
        XCTAssertEqual(item.library, "")
        XCTAssertEqual(item.image?.absoluteString, "https://covers.syracuse.cloud/Cover/VGNB/MONO/PPG5vyVG_C0qvB5oAhtqQw2/9782413075479/MEDIUM?fallback=https%3a%2f%2fbm-grenoble.fr%2fui%2fskins%2fdefault%2fportal%2ffront%2fimages%2fGeneral%2fDocType%2fMONO_MEDIUM.png")
        XCTAssertEqual(item.returnDateComponents.day, 6)
        XCTAssertEqual(item.returnDateComponents.month, 2)
        XCTAssertEqual(item.returnDateComponents.year, 2024)
    }
}
