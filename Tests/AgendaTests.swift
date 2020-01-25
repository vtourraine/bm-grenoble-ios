//
//  AgendaTests.swift
//  bmTests
//
//  Created by Vincent Tourraine on 11/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import XCTest
@testable import bm

class AgendaTests: XCTestCase {

    private func loadItems(fromFileNamed fileName: String) throws -> [AgendaItem] {
        let path = try XCTUnwrap(Bundle(for: type(of: self)).path(forResource: fileName, ofType: "html"))
        let html = try XCTUnwrap(String(contentsOfFile: path))
        let items = try XCTUnwrap(AgendaParser.parseItems(html: html))
        return items
    }

    func testParseAgendaItems1() throws {
        let items = try loadItems(fromFileNamed: "TestAgenda1")

        XCTAssertEqual(items.count, 10)

        XCTAssertEqual(items[0].title, "Le nudge, comment influencer sans contrainte")
        XCTAssertEqual(items[0].category, "Conférences")
        XCTAssertEqual(items[0].library, "Bibliothèque Kateb Yacine")
        XCTAssertEqual(items[0].summary, "Une conférence animée par Evelyn Rosset, docteur en psychologie, chercheure associée au LIP/PC2S, UGA.")
        XCTAssertEqual(items[0].link.absoluteString, "https://www.bm-grenoble.fr/688-agenda.htm?TPL_CODE=TPL_AGENDA&PAR_TPL_IDENTIFIANT=7863")
        let items0Image = try XCTUnwrap(items[0].image)
        XCTAssertEqual(items0Image.absoluteString, "https://www.bm-grenoble.fr/uploads/Image/d0/IMF_TETIERE/25362_085_1h-de-psy-2019.jpg")
        switch items[0].date {
        case .range:
            XCTFail()
        case .day(let dateComponents):
            XCTAssertEqual(dateComponents.day, 11)
            XCTAssertEqual(dateComponents.month, 1)
            XCTAssertEqual(dateComponents.year, 2020)
        }

        XCTAssertEqual(items[6].summary, "Un programme de lectures ponctuées de chansons sur une musique originale de Thierry Ronget.")
    }
}
