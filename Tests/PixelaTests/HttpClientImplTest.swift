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
