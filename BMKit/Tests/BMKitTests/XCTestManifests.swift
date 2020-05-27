import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AccountSummaryTests.allTests),
        testCase(AuthenticateTests.allTests),
        testCase(LoansTests.allTests),
    ]
}
#endif
