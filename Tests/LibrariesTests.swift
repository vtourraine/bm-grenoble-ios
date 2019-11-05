//
//  LibrariesTests.swift
//  bmTests
//
//  Created by Vincent Tourraine on 05/11/2019.
//  Copyright © 2019 Studio AMANgA. All rights reserved.
//

import XCTest
@testable import bm

class LibrariesTests: XCTestCase {

    func testLibrariesList() {
        guard let libraries = try? XCTUnwrap(Libraries.loadCityLibraries()) else {
            return
        }

        XCTAssertNotNil(libraries.lastUpdate)
        XCTAssertEqual(libraries.libraries.count, 13)
    }

}
