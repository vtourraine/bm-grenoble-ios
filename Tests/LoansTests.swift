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
        let document = Document(identifier: "", title: "To love is to love / Jehnny Beth, chant, comp., p", localNumber: "", type: "")
        XCTAssertEqual(document.formattedTitle(), "To love is to love")
    }

    func testTitleFormattingTypeSuffix() {
        let document = Document(identifier: "", title: "The social network [DVD] / David Fincher, réal. ; avec Jesse Eisenberg, Andrew Garfield, Justin Timberlake, Armie Hammer, Max Minghella. ; Aaron Sorkin, scénar.", localNumber: "", type: "DVD")
        XCTAssertEqual(document.formattedTitle(), "The social network")
    }
}
