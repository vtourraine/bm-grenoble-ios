//
//  bmTests.swift
//  bmTests
//
//  Created by Vincent Tourraine on 31/07/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import XCTest
@testable import bm

class LoansTests: XCTestCase {

    private func loadLoans(fromFileNamed fileName: String) throws -> (items: [Item], pagination: PageParser.Pagination) {
        let path = try XCTUnwrap(Bundle(for: type(of: self)).path(forResource: fileName, ofType: "html"))
        let html = try XCTUnwrap(String(contentsOfFile: path))
        let loans = try XCTUnwrap(PageParser.parseLoans(html: html))
        return loans
    }

    func testParseLoans1() throws {
        let loans = try loadLoans(fromFileNamed: "TestAccountLoans1")

        XCTAssertEqual(loans.pagination.numberOfPages, 1)
        XCTAssertEqual(loans.pagination.currentPage, 0)
        XCTAssertNil(loans.pagination.nextPage)

        XCTAssertEqual(loans.items.count, 5)
        XCTAssertEqual(loans.items[0].title, "Les dinosaures")
        XCTAssertEqual(loans.items[0].author, "Camille Moreau ; illustrations Benjamin Bécue")
        XCTAssertEqual(loans.items[0].library, "Eaux Claires")
        XCTAssertEqual(loans.items[0].returnDateComponents.day, 17)
        XCTAssertEqual(loans.items[0].returnDateComponents.month, 8)
        XCTAssertEqual(loans.items[0].returnDateComponents.year, 2019)
        let items0Image = try XCTUnwrap(loans.items[0].image)
        XCTAssertEqual(items0Image.absoluteString, "http://catalogue.bm-grenoble.fr/in/rest/Thumb/ISBN/2092578081?icon=document&amp;mat=CHILD_BOOK")
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

    func testParseLoans2() throws {
        let loans = try loadLoans(fromFileNamed: "TestAccountLoans2")

        XCTAssertEqual(loans.pagination.numberOfPages, 1)
        XCTAssertEqual(loans.pagination.currentPage, 0)
        XCTAssertNil(loans.pagination.nextPage)

        XCTAssertEqual(loans.items.count, 8)
        XCTAssertEqual(loans.items[1].title, "Hilda et le chien noir")
        XCTAssertEqual(loans.items[1].author, "Luke Pearson ; traduction Basile Béguerie")
        XCTAssertEqual(loans.items[1].library, "Jardin de Ville")
        XCTAssertEqual(loans.items[1].returnDateComponents.day, 17)
        XCTAssertEqual(loans.items[1].returnDateComponents.month, 9)
        XCTAssertEqual(loans.items[1].returnDateComponents.year, 2019)
    }

    func testParseLoans3() throws {
        let loans = try loadLoans(fromFileNamed: "TestAccountLoans3-Page1")

        XCTAssertEqual(loans.pagination.numberOfPages, 2)
        XCTAssertEqual(loans.pagination.currentPage, 0)
        XCTAssertNotNil(loans.pagination.nextPage)
        XCTAssertEqual(loans.pagination.nextPage!, URL(string: "/in/faces/accountLoans.xhtml?pageNo=2"))

        XCTAssertEqual(loans.items.count, 10)
    }

    func testParseLoansEmpty() throws {
        let loans = try loadLoans(fromFileNamed: "TestAccountLoansEmpty")

        XCTAssertEqual(loans.pagination.numberOfPages, 0)
        XCTAssertEqual(loans.pagination.currentPage, 0)
        XCTAssertNil(loans.pagination.nextPage)

        XCTAssertEqual(loans.items.count, 0)
    }

    func testTitleFormatter() {
        let itemBook = Item(title: "Sous le même ciel", author: "", library: "", returnDateComponents: DateComponents(), image: nil)
        XCTAssertEqual(itemBook.formattedTitle(), "📖 Sous le même ciel")

        let itemDVD = Item(title: "Patlabor 2 [DVD]", author: "", library: "", returnDateComponents: DateComponents(), image: nil)
        XCTAssertEqual(itemDVD.formattedTitle(), "📀 Patlabor 2")

        let itemDVDAlt = Item(title: "Vaiana : la légende du bout du monde [DVD] : = Moana", author: "", library: "", returnDateComponents: DateComponents(), image: nil)
        XCTAssertEqual(itemDVDAlt.formattedTitle(), "📀 Vaiana : la légende du bout du monde – Moana")

        let itemBD = Item(title: "Alien 3 [BLU-RAY]", author: "", library: "", returnDateComponents: DateComponents(), image: nil)
        XCTAssertEqual(itemBD.formattedTitle(), "📀 Alien 3")

        let itemGame = Item(title: "Assimemor : animals & colours [JEU]", author: "", library: "", returnDateComponents: DateComponents(), image: nil)
        XCTAssertEqual(itemGame.formattedTitle(), "🎲 Assimemor : animals & colours")
    }

    func testAuthorFormatter() {
        let item1 = Item(title: "", author: "Camille Moreau ; illustrations Benjamin Bécue", library: "", returnDateComponents: DateComponents(), image: nil)
        XCTAssertEqual(item1.formattedAuthor(), "Camille Moreau")

        let item2 = Item(title: "", author: "texte de Jean-Claude Mourlevat ; ill. de Fabienne Teyssèdre", library: "", returnDateComponents: DateComponents(), image: nil)
        XCTAssertEqual(item2.formattedAuthor(), "Jean-Claude Mourlevat")

        let item3 = Item(title: "", author: "Isao Takahata, réal. ; Joe Hisaishi, comp. ;", library: "", returnDateComponents: DateComponents(), image: nil)
        XCTAssertEqual(item3.formattedAuthor(), "Isao Takahata")

        let item4 = Item(title: "", author: "réalisé par Mamoru Oshii", library: "", returnDateComponents: DateComponents(), image: nil)
        XCTAssertEqual(item4.formattedAuthor(), "Mamoru Oshii")

        let item5 = Item(title: "", author: "scénario Wilfrid Lupano ; dessin Mayana Itoïz, Paul Cauuet", library: "", returnDateComponents: DateComponents(), image: nil)
        XCTAssertEqual(item5.formattedAuthor(), "Wilfrid Lupano")
    }
}
