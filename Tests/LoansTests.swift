//
//  LoansTests.swift
//  bmTests
//
//  Created by Vincent Tourraine on 04/03/2021.
//  Copyright © 2021 Studio AMANgA. All rights reserved.
//

import XCTest
@testable import bm

class LoansTest: XCTestCase {

    func testTitleFormatting() {
        let item = Item(title: "To love is to love / Jehnny Beth, chant, comp., p", type: "", author: "", library: "", returnDateComponents: DateComponents(), image: nil)
        XCTAssertEqual(item.formattedTitle(), "To love is to love")
    }
}
