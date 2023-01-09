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
        let loans = try loadLoans(fromFileNamed: "TestLoans-2022-1")

        XCTAssertEqual(loans.count, 5)

        let item = try XCTUnwrap(loans.first)
        XCTAssertEqual(item.title, "Bolchoi arena. 3, Révolutions")
        XCTAssertEqual(item.author, "scénario Boulet ; dessin Aseyn ; couleur Yoann Guillé, Aseyn")
        XCTAssertEqual(item.library, "")
        XCTAssertEqual(item.returnDateComponents.day, 13)
        XCTAssertEqual(item.returnDateComponents.month, 1)
        XCTAssertEqual(item.returnDateComponents.year, 2023)
    }

    func testParseLoans2() throws {
        let loans = try loadLoans(fromFileNamed: "TestLoans-2022-2")

        XCTAssertEqual(loans.count, 2)

        let item = try XCTUnwrap(loans.first)
        XCTAssertEqual(item.title, "Nima et l'ogresse")
        XCTAssertEqual(item.author, "une histoire de Pierre Bertrand ; illustrée par Chen Jiang Hong")
        XCTAssertEqual(item.library, "")
        XCTAssertEqual(item.returnDateComponents.day, 4)
        XCTAssertEqual(item.returnDateComponents.month, 2)
        XCTAssertEqual(item.returnDateComponents.year, 2023)
    }

    func testTitleFormatting() {
        let document = Document(identifier: "", title: "To love is to love / Jehnny Beth, chant, comp., p", localNumber: "", type: "")
        XCTAssertEqual(document.formattedTitle(), "To love is to love")
    }

    func testTitleFormattingTypeSuffix() {
        let document = Document(identifier: "", title: "The social network [DVD] / David Fincher, réal. ; avec Jesse Eisenberg, Andrew Garfield, Justin Timberlake, Armie Hammer, Max Minghella. ; Aaron Sorkin, scénar.", localNumber: "", type: "DVD")
        XCTAssertEqual(document.formattedTitle(), "The social network")
    }
}
