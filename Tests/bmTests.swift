//
//  bmTests.swift
//  bmTests
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import XCTest
@testable import bm

class bmTests: XCTestCase {

    func testParseLoans1() {
        let path = Bundle(for: type(of: self)).path(forResource: "TestAccountLoans1", ofType: "html")
        let html = try! String(contentsOfFile: path!)

        guard let loans = PageParser.parseLoans(html: html) else {
            XCTFail()
            return
        }

        XCTAssertEqual(loans.pagination.numberOfPages, 1)
        XCTAssertEqual(loans.pagination.currentPage, 0)

        XCTAssertEqual(loans.items.count, 5)
        XCTAssertEqual(loans.items[0].title, "Les dinosaures")
        XCTAssertEqual(loans.items[0].author, "Camille Moreau ; illustrations Benjamin Bécue")
        XCTAssertEqual(loans.items[0].library, "Eaux Claires")
        XCTAssertEqual(loans.items[0].returnDateComponents.day, 17)
        XCTAssertEqual(loans.items[0].returnDateComponents.month, 8)
        XCTAssertEqual(loans.items[0].returnDateComponents.year, 2019)
        XCTAssertEqual(loans.items[1].title, "Sous le même ciel")
        XCTAssertEqual(loans.items[1].author, "Britta Teckentrup ; traduit de l'anglais par Frédéric Rébéna")
        XCTAssertEqual(loans.items[1].library, "Eaux Claires")
        XCTAssertEqual(loans.items[1].returnDateComponents.day, 17)
        XCTAssertEqual(loans.items[1].returnDateComponents.month, 8)
        XCTAssertEqual(loans.items[1].returnDateComponents.year, 2019)
        XCTAssertEqual(loans.items[2].title, "Histoire de l'enfant et de l'oeuf")
        XCTAssertEqual(loans.items[2].author, "texte de Jean-Claude Mourlevat ; ill. de Fabienne Teyssèdre")
        XCTAssertEqual(loans.items[2].library, "Eaux Claires")
        XCTAssertEqual(loans.items[2].returnDateComponents.day, 17)
        XCTAssertEqual(loans.items[2].returnDateComponents.month, 8)
        XCTAssertEqual(loans.items[2].returnDateComponents.year, 2019)
        XCTAssertEqual(loans.items[3].title, "Le conte de la princesse Kaguya [DVD]")
        XCTAssertEqual(loans.items[3].author, "Isao Takahata, réal. ; Joe Hisaishi, comp. ;")
        XCTAssertEqual(loans.items[3].library, "Eaux Claires")
        XCTAssertEqual(loans.items[3].returnDateComponents.day, 23)
        XCTAssertEqual(loans.items[3].returnDateComponents.month, 8)
        XCTAssertEqual(loans.items[3].returnDateComponents.year, 2019)
        XCTAssertEqual(loans.items[4].title, "Patlabor 2 [DVD]")
        XCTAssertEqual(loans.items[4].author, "réalisé par Mamoru Oshii")
        XCTAssertEqual(loans.items[4].library, "Eaux Claires")
        XCTAssertEqual(loans.items[4].returnDateComponents.day, 10)
        XCTAssertEqual(loans.items[4].returnDateComponents.month, 9)
        XCTAssertEqual(loans.items[4].returnDateComponents.year, 2019)
    }

    func testParseLoans2() {
        let path = Bundle(for: type(of: self)).path(forResource: "TestAccountLoans2", ofType: "html")
        let html = try! String(contentsOfFile: path!)

        guard let loans = PageParser.parseLoans(html: html) else {
            XCTFail()
            return
        }

        XCTAssertEqual(loans.pagination.numberOfPages, 1)
        XCTAssertEqual(loans.pagination.currentPage, 0)

        XCTAssertEqual(loans.items.count, 8)
        XCTAssertEqual(loans.items[1].title, "Hilda et le chien noir")
        XCTAssertEqual(loans.items[1].author, "Luke Pearson ; traduction Basile Béguerie")
        XCTAssertEqual(loans.items[1].library, "Jardin de Ville")
        XCTAssertEqual(loans.items[1].returnDateComponents.day, 17)
        XCTAssertEqual(loans.items[1].returnDateComponents.month, 9)
        XCTAssertEqual(loans.items[1].returnDateComponents.year, 2019)
    }

    func testParseLoans3() {
        let path = Bundle(for: type(of: self)).path(forResource: "TestAccountLoans3-Page1", ofType: "html")
        let html = try! String(contentsOfFile: path!)

        guard let loans = PageParser.parseLoans(html: html) else {
            XCTFail()
            return
        }

        XCTAssertEqual(loans.pagination.numberOfPages, 2)
        XCTAssertEqual(loans.pagination.currentPage, 0)

        XCTAssertEqual(loans.items.count, 10)
    }

    func testTitleFormatter() {
        let itemBook = Item(title: "Sous le même ciel", author: "", library: "", returnDateComponents: DateComponents())
        XCTAssertEqual(itemBook.formattedTitle(), "📖 Sous le même ciel")

        let itemDVD = Item(title: "Patlabor 2 [DVD]", author: "", library: "", returnDateComponents: DateComponents())
        XCTAssertEqual(itemDVD.formattedTitle(), "📀 Patlabor 2")
    }

    func testAuthorFormatter() {
        let item1 = Item(title: "", author: "Camille Moreau ; illustrations Benjamin Bécue", library: "", returnDateComponents: DateComponents())
        XCTAssertEqual(item1.formattedAuthor(), "Camille Moreau")

        let item2 = Item(title: "", author: "texte de Jean-Claude Mourlevat ; ill. de Fabienne Teyssèdre", library: "", returnDateComponents: DateComponents())
        XCTAssertEqual(item2.formattedAuthor(), "Jean-Claude Mourlevat")

        let item3 = Item(title: "", author: "Isao Takahata, réal. ; Joe Hisaishi, comp. ;", library: "", returnDateComponents: DateComponents())
        XCTAssertEqual(item3.formattedAuthor(), "Isao Takahata")

        let item4 = Item(title: "", author: "réalisé par Mamoru Oshii", library: "", returnDateComponents: DateComponents())
        XCTAssertEqual(item4.formattedAuthor(), "Mamoru Oshii")

        let item5 = Item(title: "", author: "scénario Wilfrid Lupano ; dessin Mayana Itoïz, Paul Cauuet", library: "", returnDateComponents: DateComponents())
        XCTAssertEqual(item5.formattedAuthor(), "Wilfrid Lupano")
    }
}
