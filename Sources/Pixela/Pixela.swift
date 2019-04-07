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

public struct RawGraphDefinition: Equatable {

    public let id: String
    public let name: String
    public let unit: String
    public let type: String
    public let color: String
    public let timezone: String
    public let purgeCacheURLs: [String]

    public init(
            id: String,
            name: String,
            unit: String,
            type: String,
            color: String,
            timezone: String,
            purgeCacheURLs: [String]) {
        self.id = id
        self.name = name
        self.unit = unit
        self.type = type
        self.color = color
        self.timezone = timezone
        self.purgeCacheURLs = purgeCacheURLs
    }

    func asGraphDefinition() -> GraphDefinition {
        return GraphDefinition(raw: self)
    }
}

public struct GraphDefinition: CustomStringConvertible {

    private let raw: RawGraphDefinition

    public init(raw: RawGraphDefinition) {
        self.raw = raw
    }

    public var id: String {
        return raw.id
    }

    public var name: String {
        return raw.name
    }

    public var unit: String {
        return raw.unit
    }

    public var type: Type {
        if let t = Type(type: raw.type) {
            return t
        }
        return .unknown(raw.type)
    }

    public var color: Color {
        if let color = Color(of: raw.color) {
            return color
        }
        return .unknown(raw.color)
    }

    public var timezone: String {
        return raw.timezone
    }

    public var purgeCacheURLs: [String] {
        return raw.purgeCacheURLs
    }

    public var description: String {
        return "graph-definition[id:\(raw.id),name:\(raw.name),unit:\(raw.unit),type:\(raw.type),color:\(raw.color),timezone:\(raw.timezone),purgeCacheURLs:\(raw.purgeCacheURLs)]"
    }
}

public struct RawGraphDefinitions {
    public let graphs: [RawGraphDefinition]

    public init(graphs: [RawGraphDefinition]) {
        self.graphs = graphs
    }
}

public struct GraphDefinitions {
    public let graphs: [GraphDefinition]

    init(raw: RawGraphDefinitions) {
        let graphs = raw.graphs.map { $0.asGraphDefinition() }
        self.init(graphs: graphs)
    }

    public init(graphs: [GraphDefinition]) {
        self.graphs = graphs
    }
}
