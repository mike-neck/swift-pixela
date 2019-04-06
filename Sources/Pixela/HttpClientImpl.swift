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
    let resp: URLResponse?

    init(of resp: URLResponse?) {
        self.resp = resp
    }

    func handle() -> Result<Int, HandlingStatus> {
        let description = String(describing: resp)
        return resp.asResult(HandlingStatus.bodyNotAvailable(PixelaApiError.invalidResponse(message: "error - unknown type response \(description)")))
                .flatMap {
                    $0.statusCode(onError: HandlingStatus.bodyNotAvailable(PixelaApiError.invalidResponse(message: "error - unknown type response \(description)")))
                }
                .flatMap { (statusCode: Int) -> Result<Int, Error> in
                    if 200 <= statusCode && statusCode < 300 {
                        return .success(statusCode)
                    } else {
                        return .failure(HandlingStatus.bodyAvailable(statusCode))
                    }
                }.mapError { (err: Error) -> HandlingStatus in
                    if let error = err as? HandlingStatus {
                        return error
                    }
                    return .bodyNotAvailable(err)
                }
    }
}

enum HandlingStatus: Error {
    case bodyAvailable(_: Int)
    case bodyNotAvailable(_: Error)

    func handleIfAvailable(data: DataWrapper, using decoder: JSONDecoder) -> Error {
        switch self {
        case .bodyNotAvailable(let err): return err
        case .bodyAvailable(let statusCode):
            let result = data.unwrap().flatMap { (body: Data) -> Result<Error, Error> in
                do {
                    let pixelaResponse = try decoder.decode(PixelaResponse.self, from: body)
                    return .success(PixelaApiError.apiError(response: pixelaResponse))
                } catch {
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
    let data: DataWrapper
    let status: HttpStatusHandler
    let err: Error?

    init(decoder: JSONDecoder, data: Data?, resp: URLResponse?, err: Error?) {
        self.decoder = decoder
        self.data = DataWrapper(of: data)
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
            data.unwrap().flatMap { (body: Data) -> Result<Value, Error> in
                return self.decoder.decode(json: body, as: Value.self)
            }
        }
    }
}
