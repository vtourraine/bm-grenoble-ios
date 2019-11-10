//
//  SearchTests.swift
//  bmTests
//
//  Created by Vincent Tourraine on 10/11/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import XCTest
@testable import bm

class SearchTests: XCTestCase {

    func testSearchQuery() {
        if let query = try? XCTUnwrap(SearchEngine.encodedQuery(for: "test")) {
            XCTAssertEqual(query, "test")
        }
    }

    func testSearchQueryWithSpace() {
        if let query = try? XCTUnwrap(SearchEngine.encodedQuery(for: "test stuff")) {
            XCTAssertEqual(query, "test+stuff")
        }
    }
}
