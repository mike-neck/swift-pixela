import Foundation
@testable import Pixela
import XCTest

class HttpStatusHandlerTest: XCTestCase {

    enum HttpStatusForTest: HttpStatus {
        case status1xx
        case status200
        case status300

        var code: Int {
            switch self {
            case .status1xx: return 100
            case .status200: return 200
            case .status300: return 300
            }
        }

        func statusCode(onError: @autoclosure @escaping () -> Error) -> Result<Int, Error> {
            switch self {
            case .status1xx:return .success(self.code)
            case .status200:return .success(self.code)
            case .status300:return .success(self.code)
            }
        }
    }

    func testNil() {
        let handler = HttpStatusHandler()
        let result = handler.handle()
        result.doOn(success: { (i: Int) -> Void in
            XCTFail()
        }, failure: { (stat: HandlingStatus) -> Void in
            switch stat {
            case .bodyAvailable(_): XCTFail()
            case .bodyNotAvailable(let err): XCTAssertNotNil(err)
            }
        })
    }

    func test1xx() {
        let handler = HttpStatusHandler(stat: HttpStatusForTest.status1xx)
        let result = handler.handle()
        result.doOn(success: { (Int) -> Void in
            XCTFail()
        }, failure: { (stat: HandlingStatus) -> Void in
            switch stat {
            case .bodyAvailable(let code): XCTAssertEqual(HttpStatusForTest.status1xx.code, code)
            case .bodyNotAvailable(_): XCTFail()
            }
        })
    }

    func test2xx() {
        let handler = HttpStatusHandler(stat: HttpStatusForTest.status200)
        let result = handler.handle()
        result.doOn(success: { (code: Int) -> Void in
            XCTAssertEqual(HttpStatusForTest.status200.code, code)
        }, failure: { (HandlingStatus) -> Void in
            XCTFail()
        })
    }

    func test3xx() {
        let handler = HttpStatusHandler(stat: HttpStatusForTest.status300)
        let result = handler.handle()
        result.doOn(success: { (code: Int) -> Void in
            XCTFail()
        }, failure: { (stat: HandlingStatus) -> Void in
            switch stat {
            case .bodyAvailable(let code): XCTAssertEqual(HttpStatusForTest.status300.code, code)
            case .bodyNotAvailable(_): XCTFail()
            }
        })
    }
}

class HandlingStatusTest: XCTestCase {

    enum Err: Error, Equatable {
        case err
    }

    let json: String = """
                       {"isSuccess":false,"message":"test"}
                       """

    let decoder: JSONDecoder = JSONDecoder()

    private var maybeData: Maybe<Data> {
        return Maybe(json.data(using: .utf8))
    }

    func testBodyNotAvailable() {
        let handlingStatus: HandlingStatus = .bodyNotAvailable(Err.err)
        let error: Error = handlingStatus.handleIfAvailable(data: self.maybeData, using: decoder)
        guard let err = error as? Err else {
            XCTFail()
            return
        }
        XCTAssertEqual(Err.err, err)
    }

    func testBodyAvailableValidJson() {
        let handlingStatus: HandlingStatus = .bodyAvailable(400)
        let error: Error = handlingStatus.handleIfAvailable(data: self.maybeData, using: decoder)
        guard let err = error as? PixelaApiError else {
            XCTFail()
            return
        }
        switch err {
        case .apiError(let response): XCTAssertEqual("test", response.message)
        default: XCTFail(String(describing: err))
        }
    }

    func testBodyAvailableNilJson() {
        let handlingStatus: HandlingStatus = .bodyAvailable(400)
        let error: Error = handlingStatus.handleIfAvailable(data: Maybe(nil), using: decoder)
        guard let err = error as? PixelaApiError else {
            XCTFail()
            return
        }
        switch err {
        case .invalidResponse(let message): XCTAssertTrue(message.contains("status: 400 but body not available"), message)
        default: XCTFail(String(describing: err))
        }
    }

    func testBodyAvailableInvalidJson() {
        let handlingStatus: HandlingStatus = .bodyAvailable(400)
        let error: Error = handlingStatus.handleIfAvailable(data: Maybe("[isSuccess:true]".data(using: .utf8)), using: decoder)
        guard let err = error as? PixelaApiError else {
            XCTFail()
            return
        }
        switch err {
        case .invalidResponse(let message): XCTAssertTrue(message.contains("error - status: 400 with body: ["), message)
        default: XCTFail(String(describing: err))
        }
    }

    static var allTests = [
        ("testBodyNotAvailable",testBodyNotAvailable),
        ("testBodyAvailableValidJson",testBodyAvailableValidJson),
        ("testBodyAvailableNilJson",testBodyAvailableNilJson),
        ("testBodyAvailableInvalidJson",testBodyAvailableInvalidJson),
    ]
}
