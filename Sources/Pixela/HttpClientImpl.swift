//
// Created by mike on 2019-03-22.
//

import Foundation
import Promises

class HttpClientImpl: HttpClient {

    let baseUrl: String
    let urlSession: URLSession
    let encoder: JSONEncoder = JSONEncoder()
    let decoder: JSONDecoder = JSONDecoder()

    init(using uriSession: URLSession, baseUrl: String = PixelaClient.BASE_URL) {
        self.urlSession = uriSession
        self.baseUrl = baseUrl
    }

    func sendRequest<RES, REQ: Request>(_ request: REQ) -> Promise<RES> where RES == REQ.RESPONSE {
        return Promise<RES> { success, reject in
            if !request.path.starts(with: "/v1") {
                reject(PixelaApiError.invalidRequest(message: "error - invalid url: \(request.description)"))
                return
            }
            guard let url = URL(string: "\(self.baseUrl)/\(request.path)") else {
                reject(PixelaApiError.invalidRequest(message: "error - invalid url: \(self.baseUrl)/\(request.path)"))
                return
            }

            var body: Data?
            do {
                body = try self.encode(object: request.body())
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

            self.urlSession.dataTask(with: req, completionHandler: { (data: Data?, resp: URLResponse?, err: Error?) in
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
        }
    }

    private func encode<E>(object: E?) throws -> Data? where E: Encodable {
        if let object = object {
            do {
                return try encoder.encode(object)
            } catch {
                throw error
            }
        } else {
            return nil
        }
    }


}
