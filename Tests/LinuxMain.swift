import XCTest

import PixelaTests

var tests = [XCTestCaseEntry]()
tests += PixelaTests.allTests()
tests += CreateUserTest.allTests()
tests += PixelaClientTest.allTests()
XCTMain(tests)
