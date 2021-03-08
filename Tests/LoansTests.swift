//
//  LoansTests.swift
//  bmTests
//
//  Created by Vincent Tourraine on 04/03/2021.
//  Copyright © 2021 Studio AMANgA. All rights reserved.
//

import XCTest
@testable import BMKit
@testable import bm

class LoansTest: XCTestCase {

    func testTitleFormatting() {
        let document = Document(identifier: "", title: "To love is to love / Jehnny Beth, chant, comp., p", localNumber: "", type: "", meta: Document.Meta(creators: []))
        XCTAssertEqual(document.formattedTitle(), "To love is to love")
    }
}
