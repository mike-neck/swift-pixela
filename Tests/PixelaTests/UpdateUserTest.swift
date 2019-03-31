import Foundation
@testable import Pixela
import XCTest
import Promises


class UpdateUserTest: XCTestCase {

    func testUpdateUser() {
        let httpClient = MockHttpClient { (upd: UpdateUserRequest) throws -> PixelaResponse in
            XCTAssertEqual(upd.path, "/v1/users/test-user")
            XCTAssertEqual(upd.httpMethod, HttpMethod.put)
            guard let body = upd.body() else {
                XCTFail("body is nil")
                throw TestFail.failure
            }
            XCTAssertEqual(body, UpdateUser(newToken: "new-token"))
            return PixelaResponse(isSuccess: true, message: "success")
        }
        let pixela = Pixela(username: "test-user", token: "test-token", httpClient: httpClient)
        let promise: Promise<Pixela> = pixela.updateUser(newToken: "new-token")
        promise.then(on: .main) { (px: Pixela) -> Void in
            XCTAssertEqual(px.token, "new-token")
        }
    }
}
