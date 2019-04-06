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

struct CodecTestObj: Codable, Equatable {
    let value: String

    init(value: String) {
        self.value = value
    }
}

class JsonDecoderTest: XCTestCase {

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

class JsonEncoderTest: XCTestCase {

    let encoder = JSONEncoder()

    func testEncodeSome() {
        let object = CodecTestObj(value: "encoding 2 json")
        let result = encoder.encodeJson(object)
        result.doOn(success: { (data: Data?) -> Void in
            XCTAssertNotNil(data)
            guard let json = data else {
                XCTFail("not nil")
                return
            }
            let string = String(data: json, encoding: .utf8)
            XCTAssertEqual("""
                           {"value":"encoding 2 json"}
                           """, string)
        }, failure: { (Error) -> Void in
            XCTFail()
        })
    }

    func testEncodeNone() {
        let object: CodecTestObj? = nil
        let result = encoder.encodeJson(object)
        result.doOn(success: { (data: Data?) -> Void in
            XCTAssertNil(data)
        }, failure: { (Error) -> Void in
            XCTFail()
        })
    }

    static var allTests = [
        ("testEncodeSome", testEncodeSome),
        ("testEncodeNone", testEncodeNone)
    ]
}

class DataWrapperTest: XCTestCase {

    func testNoneData() {
        let data: Data? = nil
        let wrapper = DataWrapper(of: data)
        wrapper.unwrap().doOn(success: { (d: Data) -> Void in
            XCTFail(String(data: d, encoding: .utf8) ?? "\(d)")
        }, failure: { (err: Error) -> Void in
            XCTAssertNotNil(err)
        })
    }

    func testSomeData() {
        let data = Data(repeating: UInt8(0xa), count: 10)
        let wrapper = DataWrapper(of: data)
        wrapper.unwrap().doOn(success: { (d: Data) -> Void in
            XCTAssertEqual(data, d)
        }, failure: { (Error) -> Void in
            XCTFail()
        })
    }

    static var allTests = [
        ("testNoneData", testNoneData),
        ("testSomeData", testSomeData),
    ]
}
