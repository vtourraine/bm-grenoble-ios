//
//  AgendaTests.swift
//  bmTests
//
//  Created by Vincent Tourraine on 11/01/2020.
//  Copyright © 2020-2025 Studio AMANgA. All rights reserved.
//

import XCTest
@testable import bm

class AgendaTests: XCTestCase {

    private func loadItems(fromFileNamed fileName: String) throws -> [AgendaItem] {
        let path = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: fileName, withExtension: "json"))
        let data = try Data(contentsOf: path)
        if let items = AgendaParser.parseItems(jsonData: data) {
            return items
        }
        else {
            XCTFail()
            return []
        }
    }

    func testParseAgendaItems() throws {
        let parsedObjects = try loadItems(fromFileNamed: "SearchNewsReponse-2024-03")

        let items = parsedObjects
        XCTAssertEqual(items.count, 12)

        XCTAssertEqual(items[0].title, "Atelier de curiosité")
        XCTAssertEqual(items[0].category, "Atelier")
        XCTAssertEqual(items[0].library, "Bibliothèque Teisseire Malherbe")
        XCTAssertEqual(items[0].summary, "Envie de découverte, de partage et de créativité ? Rendez-vous aux ateliers de curiosité ! En cette période de carnaval, venez créer des masques pour vous déguiser.")
        XCTAssertEqual(items[0].link.absoluteString, "https://bm-grenoble.fr/Default/doc/CALENDAR/321/atelier-de-curiosite")
        let items0Image = try XCTUnwrap(items[0].image)
        XCTAssertEqual(items0Image.absoluteString, "https://bm-grenoble.fr/basicimagedownload.ashx?itemGuid=788EBA00-0334-4B2A-B845-6020A9B95AD6")
        switch items[0].date {
        case .range(let startDate, let endDate):
            XCTAssertEqual(startDate.day, 26)
            XCTAssertEqual(startDate.month, 3)
            XCTAssertEqual(startDate.year, 2024)
            XCTAssertEqual(startDate.hour, 16)
            XCTAssertEqual(startDate.minute, 30)
            XCTAssertEqual(endDate.hour, 17)
            XCTAssertEqual(endDate.minute, 30)
        case .day:
            XCTFail()
        case .none:
            XCTFail()
        }
    }
}
