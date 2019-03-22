import Foundation
import Promises

public struct PixelaClient {

    static var BASE_URL = "https://pixe.la"

    static var X_USER_TOKEN = "X-USER-TOKEN"

    private let httpClient: HttpClient

    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }

    public init() {
        let urlSession = URLSession.shared
        self.init(httpClient: HttpClientImpl(using: urlSession))
    }

    public init(server: String) {
        let urlSession = URLSession.shared
        self.init(httpClient: HttpClientImpl(using: urlSession, baseUrl: server))
    }

    public init(using urlSession: URLSession) {
        self.init(httpClient: HttpClientImpl(using: urlSession))
    }

    public init(using urlSession: URLSession, server: String) {
        self.init(httpClient: HttpClientImpl(using: urlSession, baseUrl: server))
    }

    public func createUser(
            token: String,
            username: String,
            agreeTermsOfService: Answer,
            notMinor: Answer) -> Promise<Pixela> {
        let createUserRequest = CreateUserRequest(
                token: token,
                username: username,
                agreeTermsOfService: agreeTermsOfService,
                notMinor: notMinor)
        return httpClient.sendRequest(createUserRequest)
                .then { (response: PixelaResponse) in
                    return Promise { () -> Pixela in
                        guard true == response.isSuccess else {
                            throw PixelaApiError.invalidResponse(message: "error - \(response.message)")
                        }
                        return Pixela(username: username, token: token, httpClient: self.httpClient)
                    }
                }
    }
}


protocol Api {
    associatedtype API_RESULT

    func call() -> Promise<API_RESULT>
}

public enum PixelaApiError: Error {
    case invalidRequest(message: String)
    case invalidResponse(message: String)
    case apiError(response: PixelaResponse)
    case unexpected(error: Error)
}

public struct Pixela {
    let username: String
    let token: String

    private let httpClient: HttpClient

    init(username: String, token: String, httpClient: HttpClient) {
        self.username = username
        self.token = token
        self.httpClient = httpClient
    }
}
