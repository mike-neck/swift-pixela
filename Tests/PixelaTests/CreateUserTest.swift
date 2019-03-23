import Foundation
import XCTest
@testable import Pixela

final class CreateUserTest: XCTestCase {

    func testToJson() {
        let encoder = JSONEncoder()
        let createUserBody = CreateUser(token: "test-token", username: "pixela-user", agreeTermsOfService: .yes, notMinor: .yes)
        let data: Data = try! encoder.encode(createUserBody)
        let json = String(decoding: data, as: UTF8.self)
        XCTAssertTrue(json.contains("\"username\":\"pixela-user\""), "contains username")
        XCTAssertTrue(json.contains("\"agreeTermsOfService\":\"yes\""), "contains agreeTermOfService")
        XCTAssertTrue(json.contains("\"token\":\"test-token\""), "contains token")
        XCTAssertTrue(json.contains("\"notMinor\":\"yes\""), "contains notMinor")
    }

    func testDescription() {
        let createUser = CreateUser(token: "aaa-bbb", username: "test-user", agreeTermsOfService: .yes, notMinor: .no)
        let string: String = String(describing: createUser)
        XCTAssertEqual("[token=aaa-bbb,username=test-user,agreeTermsOfService=yes,notMinor=no]", string)
    }

    static var allTests = [
        ("testToJson", testToJson),
    ]
}

final class CreateUserRequestTest: XCTestCase {
    let request = CreateUserRequest(token: "test-token", username: "test-user", agreeTermsOfService: .yes, notMinor: .no)

    func testPath() {
        XCTAssertEqual("/v1/users", request.path)
    }
}
