//
// Created by mike on 2019-03-22.
//

import Foundation
import Promises

class HttpClientImpl: HttpClient {

    let baseUrl: String
    let urlSession: URLSession
    let queue: DispatchQueue
    let encoder: JSONEncoder = JSONEncoder()
    let decoder: JSONDecoder = JSONDecoder()

    init(using uriSession: URLSession,
         baseUrl: String = PixelaClient.BASE_URL,
         queue: DispatchQueue = .global(qos: .default)) {
        self.urlSession = uriSession
        self.baseUrl = baseUrl
        self.queue = queue
    }

    func sendRequest<RES, REQ: Request>(_ request: REQ) -> Promise<RES> where RES == REQ.RESPONSE {
        return Promise<RES>(on: queue) { success, reject in
            if !request.path.starts(with: "/v1") {
                reject(PixelaApiError.invalidRequest(message: "error - invalid url: \(request.description)"))
                return
            }
            guard let url = URL(string: "\(self.baseUrl)\(request.path)") else {
                reject(PixelaApiError.invalidRequest(message: "error - invalid url: \(self.baseUrl)\(request.path)"))
                return
            }

            var body: Data?
            do {
                body = try self.encoder.encode(object: request.body())
            } catch {
                reject(PixelaApiError.unexpected(error: error))
                return
            }

            var req = URLRequest(url: url)
            req.httpMethod = request.httpMethod.asString
            req.httpBody = body
            req.addValue("User-Agent", forHTTPHeaderField: "swift-pixela-client")

            if let token = request.userToken {
                req.addValue(PixelaClient.X_USER_TOKEN, forHTTPHeaderField: token)
            }

            let task = self.urlSession.dataTask(with: req, completionHandler: { (data: Data?, resp: URLResponse?, err: Error?) in
                if let error = err {
                    reject(PixelaApiError.unexpected(error: error))
                    return
                }
                guard let response = resp as? HTTPURLResponse else {
                    let description = String(describing: resp)
                    reject(PixelaApiError.invalidResponse(message: "error - unknown type response \(description)"))
                    return
                }

                let statusCode = response.statusCode
                guard 200 <= statusCode && statusCode < 300 else {
                    guard let body = data else {
                        reject(PixelaApiError.invalidResponse(message: "error - status: \(statusCode) without body"))
                        return
                    }
                    do {
                        let pixelaResponse = try self.decoder.decode(PixelaResponse.self, from: body)
                        reject(PixelaApiError.apiError(response: pixelaResponse))
                        return
                    } catch {
                        let json = String(data: body, encoding: .utf8) ?? "[decoding error]"
                        reject(PixelaApiError.invalidResponse(message: "error - status: \(statusCode) with body: \(json)"))
                        return
                    }
                }

                guard let body = data else {
                    reject(PixelaApiError.invalidResponse(message: "error - api is success without response body"))
                    return
                }

                do {
                    let pixelaResponse = try self.decoder.decode(RES.self, from: body)
                    success(pixelaResponse)
                } catch {
                    let json = String(data: body, encoding: .utf8) ?? "[decoding error]"
                    reject(PixelaApiError.invalidResponse(message: "error - api is success but decoding response failed: \(json)"))
                }
            })
            task.resume()
        }
    }
}

func handleResponseError(_ err: Error?) -> Result<Void, Error> {
    if let error = err {
        return .failure(PixelaApiError.unexpected(error: error))
    }
    return .success(())
}

struct HttpStatusHandler {
    let stat: Maybe<HttpStatus>

    init(of resp: URLResponse?) {
        self.stat = Maybe(resp)
    }

    init(stat: HttpStatus) {
        self.stat = Maybe(stat)
    }

    init() {
        self.stat = Maybe(nil)
    }

    func handle() -> Result<Int, HandlingStatus> {
        let description = String(describing: stat)
        return stat
                .get(or: HandlingStatus.bodyNotAvailable(PixelaApiError.invalidResponse(message: "error - unknown type response \(description)")))
                .flatMap { (response: HttpStatus) -> Result<Int, Error> in
                    response.statusCode(onError: HandlingStatus.bodyNotAvailable(PixelaApiError.invalidResponse(message: "error - unknown type response \(description)")))
                }
                .flatMap { (statusCode: Int) -> Result<Int, Error> in
                    return statusCode.isSuccess(or: HandlingStatus.bodyAvailable(statusCode))
                }.mapError { (err: Error) -> HandlingStatus in
                    if let error = err as? HandlingStatus {
                        return error
                    }
                    return .bodyNotAvailable(err)
                }
    }
}

fileprivate extension Int {
    func isSuccess(or error: @autoclosure @escaping () -> Error) -> Result<Int, Error> {
        if 200 <= self && self < 300 {
            return .success(self)
        } else {
            return .failure(error())
        }
    }
}

enum HandlingStatus: Error {
    case bodyAvailable(_: Int)
    case bodyNotAvailable(_: Error)

    func handleIfAvailable(data: Maybe<Data>, using decoder: JSONDecoder) -> Error {
        switch self {
        case .bodyNotAvailable(let err): return err
        case .bodyAvailable(let statusCode):
            let result = data.get(or: PixelaApiError.invalidResponse(message: "error - status: \(statusCode) but body not available"))
                    .flatMap { (body: Data) -> Result<Error, Error> in
                        let result = decoder.decode(json: body, as: PixelaResponse.self)
                        return result.map {
                                    PixelaApiError.apiError(response: $0)
                                }
                                .flatMapError { _ in
                                    let json = String(data: body, encoding: .utf8) ?? "[decoding error]"
                                    return .success(PixelaApiError.invalidResponse(message: "error - status: \(statusCode) with body: \(json)"))
                                }
                    }.flatMapError { (err: Error) -> Result<Error, Error> in
                        return .success(err)
                    }
            do {
                return try result.get()
            } catch {
                return error
            }
        }
    }
}

struct CompletionHandler {

    let decoder: JSONDecoder
    let data: Maybe<Data>
    let status: HttpStatusHandler
    let err: Error?

    init(decoder: JSONDecoder, data: Data?, resp: URLResponse?, err: Error?) {
        self.decoder = decoder
        self.data = Maybe(data)
        self.status = HttpStatusHandler(of: resp)
        self.err = err
    }

    func handle<Value: Codable>() -> Result<Value, Error> {
        return handleResponseError(err).flatMap {
            (Void) -> Result<Int, Error> in
            status.handle().mapError {
                $0.handleIfAvailable(data: self.data, using: self.decoder)
            }
        }.flatMap { (_: Int) -> Result<Value, Error> in
            data.get(or: PixelaApiError.invalidResponse(message: "error - response body is not available"))
                    .flatMap { (body: Data) -> Result<Value, Error> in
                        return self.decoder.decode(json: body, as: Value.self)
                    }
        }
    }
}
