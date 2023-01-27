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
        XCTAssertEqual(item.image?.absoluteString, "http://catalogue.bm-grenoble.fr/in/rest/Thumb/image?id=p%3A%3Ausmarcdef_0001488730&amp;isbn=9782413039952&amp;ean=9782413039952&amp;author=Boulet+%281975-....%29&amp;title=Bolchoi+arena.+3%2C+R%C3%A9volutions+%2F+sc%C3%A9nario+Boulet+%3B+dessin+Aseyn+%3B+couleur+Yoann+Guill%C3%A9%2C+Aseyn&amp;year=2022&amp;publisher=Delcourt&amp;TypeOfDocument=GrenoblePhysicalDocument&amp;mat=Livres&amp;ct=true&amp;size=256&amp;isPhysical=1&amp;siteId=mainSite")
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

    func testParseLoansWithLibrary() throws {
        let loans = try loadLoans(fromFileNamed: "TestLoans-2023-1")

        XCTAssertEqual(loans.count, 8)

        let item = try XCTUnwrap(loans.first)
        XCTAssertEqual(item.author, "[ill. par] Sempé ; [texte de] Goscinny")
        XCTAssertEqual(item.library, "Arlequin")
    }
}
