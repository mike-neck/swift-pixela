import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CreateUserTest.allTests),
        testCase(PixelaTests.allTests),
        testCase(PixelaClientTest.allTests),
    ]
}
#endif
