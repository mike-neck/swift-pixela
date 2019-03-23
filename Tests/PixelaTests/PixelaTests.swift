import XCTest
@testable import Pixela
import Promises

final class PixelaTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(1, 1)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

final class PixelaClientTest: XCTestCase {

    func ignore_testPixelaClientCreateUser() {
        let client = PixelaClient()
        let promise: Promise<Pixela> = client.createUser(token: "test-token", username: "test-swift-pixela-client", agreeTermsOfService: .yes, notMinor: .yes)
        let semaphore = DispatchSemaphore(value: 0)
        promise.then(on: .global()) { (pixela: Pixela) -> Void in
            print(pixela)
            semaphore.signal()
        }.catch(on: .global()) { error in
            print("failed: \(error)")
            semaphore.signal()
        }
        semaphore.wait()
    }

    static var allTests: [(String, () -> Void)] = [
//        ("testPixelaClientCreateUser", ignore_testPixelaClientCreateUser)
    ]
}
