import Foundation
@testable import Pixela
import Promises
import XCTest

class DeleteUserTest: XCTestCase {

    func testDeleteUser() {
        let httpClient = MockHttpClient(function: { (req: DeleteUserRequest) -> PixelaResponse in
            XCTAssertEqual("/v1/users/test-user", req.path)
            XCTAssertEqual(HttpMethod.delete, req.httpMethod)
            XCTAssertNil(req.body())
            XCTAssertEqual("test-token", req.userToken)
            XCTAssertTrue(req.responseType() == PixelaResponse.self)
            return PixelaResponse(isSuccess: true, message: "success")
        })
        let pixela = Pixela(username: "test-user", token: "test-token", httpClient: httpClient)
        let semaphore = DispatchSemaphore(value: 0)
        pixela.deleteUser()
                .then(on: .global()) {
                    XCTAssertEqual(1, 1)
                    semaphore.signal()
                }.catch(on: .global()) { (err: Error) -> Void in
                    XCTFail("error not expected: \(err)")
                    semaphore.signal()
                }
        semaphore.wait()
    }
}
