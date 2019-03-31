import Foundation
@testable import Pixela
import Promises

struct MockHttpClient<RESPONSE, REQUEST: Request>: HttpClient where RESPONSE == REQUEST.RESPONSE {

    let function: (REQUEST) throws -> RESPONSE

    init(function: @escaping (REQUEST) throws -> RESPONSE) {
        self.function = function
    }

    var queue: DispatchQueue {
        return DispatchQueue.global(qos: .default)
    }

    func sendRequest<RES, REQ: Request>(_ request: REQ) -> Promise<RES> where RES == REQ.RESPONSE {
        if REQUEST.self == REQ.self && RES.self == RESPONSE.self {
            return Promise(on: queue) { () throws -> REQ.RESPONSE in
                return try self.function(request as! REQUEST) as! RES
            }
        } else {
            return Promise(on: queue) { () -> REQ.RESPONSE in
                throw MockingError.error("unsupported type")
            }
        }
    }
}

enum MockingError: Error {
    case error(_ message: String)
}

enum TestFail: Error {
    case failure
}
