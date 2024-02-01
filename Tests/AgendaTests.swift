//
//  AgendaTests.swift
//  bmTests
//
//  Created by Vincent Tourraine on 11/01/2020.
//  Copyright © 2020-2021 Studio AMANgA. All rights reserved.
//

import XCTest
@testable import bm

class AgendaTests: XCTestCase {

    private func loadItems(fromFileNamed fileName: String) throws -> (items: [AgendaItem], pagination: AgendaParser.Pagination) {
        let path = try XCTUnwrap(Bundle(for: type(of: self)).path(forResource: fileName, ofType: "rss"))
        let rss = try XCTUnwrap(String(contentsOfFile: path))
        let items = try XCTUnwrap(AgendaParser.parseItems(rss: rss))
        return items
    }

    func testParseRSSFeed() throws {
        let parsedObjects = try loadItems(fromFileNamed: "TestAgenda-2024-1")

        XCTAssertNil(parsedObjects.pagination.nextPage)
        // let nextPageURL = try XCTUnwrap(parsedObjects.pagination.nextPage)
        // XCTAssertEqual(nextPageURL.absoluteString, "https://www.bm-grenoble.fr/688-agenda.htm?TPL_CODE=TPL_AGENDALISTE&ip=2&op=AGP_DATEFIN+asc&cp=998b0016113da5c36d2a&mp=10#p")

        let items = parsedObjects.items
        XCTAssertEqual(items.count, 2)

        XCTAssertEqual(items[0].title, "Parcoursup : les algorithmes et leurs impacts")
        XCTAssertEqual(items[0].category, "Conférence - débat")
        XCTAssertEqual(items[0].library, "Bibliothèque Kateb Yacine")
        // XCTAssertEqual(items[0].summary, "Une conférence animée par Evelyn Rosset, docteur en psychologie, chercheure associée au LIP/PC2S, UGA.")
        XCTAssertEqual(items[0].link.absoluteString, "https://bm-grenoble.fr/Default/doc/CALENDAR/40/parcoursup-les-algorithmes-et-leurs-impacts")
        let items0Image = try XCTUnwrap(items[0].image)
        XCTAssertEqual(items0Image.absoluteString, "https://bm-grenoble.fr/basicimagedownload.ashx?itemGuid=DB23C569-C01C-45B7-9E83-F78A2A04CCD6")
        switch items[0].date {
        case .range:
            XCTFail()
        case .day(let dateComponents):
            XCTAssertEqual(dateComponents.day, 9)
            XCTAssertEqual(dateComponents.month, 2)
            XCTAssertEqual(dateComponents.year, 2024)
        case .none:
            XCTFail()
        }
    }
}
