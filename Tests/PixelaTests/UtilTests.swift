import Foundation
@testable import Pixela
import XCTest

class OptionalTest: XCTestCase {

    enum TestingError: Error {
        case error
    }

    func testSome() {
        let someValue: String? = "foo"
        let result: Result<String, Error> = someValue.asResult(TestingError.error)
        result.doOn(success: { (string: String) -> Void in
            XCTAssertEqual("foo", string)
        }, failure: { (err: Error) -> Void in
            XCTAssertNil(err)
        })
    }

    func testNone() {
        let noneValue: String? = nil
        let result: Result<String, Error> = noneValue.asResult(TestingError.error)
        result.doOn(success: { (string: String) -> Void in
            XCTAssertNil(string)
        }, failure: { (err: Error) -> Void in
            XCTAssertNotNil(err as? TestingError)
        })
    }

    static var allTests = [
        ("testSome", testSome),
        ("testNone", testNone),
    ]
}

struct CodecTestObj: Decodable, Equatable {
    let value: String

    init(value: String) {
        self.value = value
    }
}

class JsonDecoderTest {

    let decoder = JSONDecoder()

    func testDecode() {
        let json = """
                   {"value":"test value"}
                   """
        let data = json.data(using: .utf8)
        guard let body = data else {
            XCTFail()
            return
        }
        decoder.decode(json: body, as: CodecTestObj.self).doOn(success: { (obj: CodecTestObj) -> Void in
            XCTAssertEqual(CodecTestObj(value: "test value"), obj)
        }, failure: { (Error) -> Void in
            XCTFail()
        })
    }

    static var allTests = [
        ("testDecode", testDecode)
    ]
}
