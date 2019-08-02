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

    func testParseLoans() {
        let path = Bundle(for: type(of: self)).path(forResource: "TestAccountLoans", ofType: "html")
        let html = try! String(contentsOfFile: path!)
        let books = PageParser.parseLoans(html: html)
        XCTAssertEqual(books.count, 5)
        XCTAssertEqual(books[0].title, "Les dinosaures")
        XCTAssertEqual(books[0].author, "Camille Moreau ; illustrations Benjamin Bécue")
        XCTAssertEqual(books[0].library, "Eaux Claires")
        XCTAssertEqual(books[0].returnDateComponents.day, 17)
        XCTAssertEqual(books[0].returnDateComponents.month, 8)
        XCTAssertEqual(books[0].returnDateComponents.year, 2019)
        XCTAssertEqual(books[1].title, "Sous le même ciel")
        XCTAssertEqual(books[1].author, "Britta Teckentrup ; traduit de l'anglais par Frédéric Rébéna")
        XCTAssertEqual(books[1].library, "Eaux Claires")
        XCTAssertEqual(books[1].returnDateComponents.day, 17)
        XCTAssertEqual(books[1].returnDateComponents.month, 8)
        XCTAssertEqual(books[1].returnDateComponents.year, 2019)
        XCTAssertEqual(books[2].title, "Histoire de l'enfant et de l'oeuf")
        XCTAssertEqual(books[2].author, "texte de Jean-Claude Mourlevat ; ill. de Fabienne Teyssèdre")
        XCTAssertEqual(books[2].library, "Eaux Claires")
        XCTAssertEqual(books[2].returnDateComponents.day, 17)
        XCTAssertEqual(books[2].returnDateComponents.month, 8)
        XCTAssertEqual(books[2].returnDateComponents.year, 2019)
        XCTAssertEqual(books[3].title, "Le conte de la princesse Kaguya [DVD]")
        XCTAssertEqual(books[3].author, "Isao Takahata, réal. ; Joe Hisaishi, comp. ;")
        XCTAssertEqual(books[3].library, "Eaux Claires")
        XCTAssertEqual(books[3].returnDateComponents.day, 23)
        XCTAssertEqual(books[3].returnDateComponents.month, 8)
        XCTAssertEqual(books[3].returnDateComponents.year, 2019)
        XCTAssertEqual(books[4].title, "Patlabor 2 [DVD]")
        XCTAssertEqual(books[4].author, "réalisé par Mamoru Oshii")
        XCTAssertEqual(books[4].library, "Eaux Claires")
        XCTAssertEqual(books[4].returnDateComponents.day, 10)
        XCTAssertEqual(books[4].returnDateComponents.month, 9)
        XCTAssertEqual(books[4].returnDateComponents.year, 2019)
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
    }
}
