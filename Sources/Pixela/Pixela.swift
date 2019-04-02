import Foundation
import Promises

public struct Pixela: CustomStringConvertible {
    let username: String
    let token: String

    fileprivate let httpClient: HttpClient

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

    func createGraph(id: String,
                     name: String,
                     unit: String,
                     type: Type,
                     color: Color,
                     timezone: String = "UTC",
                     selfSufficient: DiffType? = nil) -> Promise<Graph> {
        let request = CreateGraphRequest(
                pixela: self,
                createGraph: CreateGraph(
                        id: id,
                        name: name,
                        unit: unit,
                        type: type,
                        color: color,
                        timezone: timezone,
                        selfSufficient: selfSufficient))
        let queue = httpClient.queue
        let px = self
        return httpClient.sendRequest(request)
                .then(on: queue) { (response: PixelaResponse) throws -> Promise<Graph> in
                    return Promise(on: queue) { () -> Graph in
                        guard  true == response.isSuccess else {
                            throw PixelaApiError.invalidResponse(message: "error - \(response.message)")
                        }
                        return Graph(pixela: px, graphId: id)
                    }
                }
    }
}

public struct Graph: CustomStringConvertible {

    private let pixela: Pixela
    private let graphId: String

    public init(pixela: Pixela, graphId: String) {
        self.pixela = pixela
        self.graphId = graphId
    }

    public var description: String {
        return "graph[username:\(pixela.username),graph:\(graphId)]"
    }
}
