//
//  DocumentTests.swift
//  BMKitTests
//
//  Created by Vincent Tourraine on 04/03/2021.
//

import XCTest
@testable import BMKit

@available(iOS 10.0, *)
final class DocumentTests: XCTestCase {
    func testParseResponse() throws {
        let response = try decodeJSON(DocumentResponse.self, from: "get-resolvebyseqno-response-body.json")

        XCTAssertEqual(response.results.count, 4)
        XCTAssertEqual(response.results[0].title, "Adrastée. 1 / Mathieu Bablet")
        XCTAssertEqual(response.results[0].type, "Livres")
        XCTAssertEqual(response.results[0].meta.creators.count, 1)
        let creatorNameComponents = try XCTUnwrap(response.results[0].meta.creators[0].nameComponents())
        XCTAssertEqual(creatorNameComponents.givenName, "Mathieu")
        XCTAssertEqual(creatorNameComponents.familyName, "Bablet")
        XCTAssertEqual(response.results[0].imageURL?.absoluteString, "https://catalogue.bm-grenoble.fr/in/rest/Thumb/image?id=p%3A%3Ausmarcdef_0001314033&isbn=9782359104035&ean=9782359104035&author=Bablet%2C+Mathieu+%281987-....%29&title=Adrast%C3%A9e.+1+%2F+Mathieu+Bablet&year=2013&publisher=Ankama&TypeOfDocument=GrenoblePhysicalDocument&mat=Livres&ct=true&size=256&isPhysical=1")
    }

    static var allTests = [
        ("testParseResponse", testParseResponse),
    ]
}
