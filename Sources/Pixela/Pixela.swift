import Foundation
import Promises

public struct Pixela: CustomStringConvertible {
    let username: String
    let token: String

    private let httpClient: HttpClient

    init(username: String, token: String, httpClient: HttpClient) {
        self.username = username
        self.token = token
        self.httpClient = httpClient
    }

    public var description: String {
        return "pixela[username:\(username),token:\(token)]"
    }

    func updateUser(newToken: String) -> Promise<Pixela> {
        let request = UpdateUserRequest(pixela: self, newToken: newToken)
        let queue = httpClient.queue
        return httpClient.sendRequest(request)
                .then(on: queue) { (response: PixelaResponse) throws -> Promise<Pixela> in
                    return Promise(on: queue) { () -> Pixela in
                        guard true == response.isSuccess else {
                            throw PixelaApiError.invalidResponse(message: "error - \(response.message)")
                        }
                        return Pixela(username: self.username, token: newToken, httpClient: self.httpClient)
                    }
                }
    }

    func deleteUser() -> Promise<Void> {
        let request = DeleteUserRequest(pixela: self)
        let queue = httpClient.queue
        return httpClient.sendRequest(request)
        .then(on: queue) { (response: PixelaResponse) throws -> Promise<Void> in
            return Promise(on: queue) { () -> Void in
                guard true == response.isSuccess else {
                    throw PixelaApiError.invalidResponse(message: "error - \(response.message)")
                }
                return ()
            }
        }
    }
}
