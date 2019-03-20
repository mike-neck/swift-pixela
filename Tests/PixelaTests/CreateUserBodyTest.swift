import Foundation
import XCTest
@testable import Pixela

final class CreateUserBodyTest: XCTestCase {

    func testToJson() {
        let encoder = JSONEncoder()
        let createUserBody = CreateUserBody(token: "test-token", username: "pixela-user", agreeTermsOfService: .yes, notMinor: .yes)
        let data: Data = try! encoder.encode(createUserBody)
        let json = String(decoding: data, as: UTF8.self)
        XCTAssertTrue(json.contains("\"username\":\"pixela-user\""), "contains username")
        XCTAssertTrue(json.contains("\"agreeTermsOfService\":\"yes\""), "contains agreeTermOfService")
        XCTAssertTrue(json.contains("\"token\":\"test-token\""), "contains token")
        XCTAssertTrue(json.contains("\"notMinor\":\"yes\""), "contains notMinor")
    }

    static var allTests = [
        ("testToJson", testToJson),
    ]
}
