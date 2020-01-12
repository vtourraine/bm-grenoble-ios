//
//  NewsTests.swift
//  bmTests
//
//  Created by Vincent Tourraine on 09/01/2020.
//  Copyright © 2020 Studio AMANgA. All rights reserved.
//

import XCTest
@testable import bm

class NewsTests: XCTestCase {

    private func loadItems(fromFileNamed fileName: String) throws -> [NewsItem] {
        let path = try XCTUnwrap(Bundle(for: type(of: self)).path(forResource: fileName, ofType: "html"))
        let html = try XCTUnwrap(String(contentsOfFile: path))
        let items = try XCTUnwrap(NewsParser.parseNewsItems(html: html))
        return items
    }

    func testParseNewsItems1() throws {
        let items = try loadItems(fromFileNamed: "TestNews1")

        XCTAssertEqual(items.count, 10)

        XCTAssertEqual(items[0].title, "La nuit de la lecture les 16, 17 et 18 janvier")
        XCTAssertEqual(items[0].summary, "Rencontres, lectures, conférences, soirée jeux, veillée en musique, théâtre d'improvisation trois soirées à déguster dans 6 bibliothèques du réseau")
        XCTAssertEqual(items[0].link.absoluteString, "https://www.bm-grenoble.fr/692-actualite.htm?TPL_CODE=TPL_ACTUALITE&PAR_TPL_IDENTIFIANT=1456")
        XCTAssertNil(items[0].image)

        XCTAssertEqual(items[1].title, "La Nuit de la lecture sous le signe du Partage")
        XCTAssertEqual(items[1].summary, "Rencontres, conférences,jeux, musique, théâtre d’improvisation, de belles découvertes. Régis Debray, Françoise Giraud, Milo de Angelis partageront avec nous ces soirées dans les bibliothèques")
        XCTAssertEqual(items[1].link.absoluteString, "https://www.bm-grenoble.fr/1984-nuit-de-la-lecture.htm?")
        let items1Image = try XCTUnwrap(items[1].image)
        XCTAssertEqual(items1Image.absoluteString, "https://www.bm-grenoble.fr/uploads/Image/a7/IMF_TETIERE/25491_878_nuit-de-la-lecture.jpg")
    }
}
