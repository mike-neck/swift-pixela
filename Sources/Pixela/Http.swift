import Foundation
import Promises

public protocol ApiRequest {
    associatedtype RESPONSE: Decodable
    associatedtype BODY: Encodable

    var path: String { get }

    var httpMethod: HttpMethod { get }

    var userToken: String? { get }

    func body() -> BODY?

    func responseType() -> RESPONSE.Type
}

public typealias Request = ApiRequest & CustomStringConvertible

public enum HttpMethod {
    case get
    case post
    case put
    case delete

    var asString: String {
        get {
            switch self {
            case .get:    return "GET"
            case .post:   return "POST"
            case .put:    return "PUT"
            case .delete: return "DELETE"
            }
        }
    }
}

public protocol HttpClient {

    func sendRequest<RES, REQ: Request>(_ request: REQ) -> Promise<RES>
            where RES == REQ.RESPONSE
}
