import XCTest
import BMKitTests

var tests = [XCTestCaseEntry]()
tests += AccountSummaryTests.allTests()
tests += AuthenticateTests.allTests()
tests += LoansTests.allTests()
XCTMain(tests)
