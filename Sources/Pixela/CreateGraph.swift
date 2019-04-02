import Foundation

struct CreateGraph: Codable, CustomStringConvertible {

    let id: String
    let name: String
    let unit: String
    let type: String
    let color: String
    let timezone: String
    let selfSufficient: String?

    private init(id: String,
                 name: String,
                 unit: String,
                 typeAsString: String,
                 colorAsString: String,
                 timezone: String,
                 selfSufficientAsString: String?) {
        self.id = id
        self.name = name
        self.unit = unit
        self.type = typeAsString
        self.color = colorAsString
        self.timezone = timezone
        self.selfSufficient = selfSufficientAsString
    }

    init(id: String,
         name: String,
         unit: String,
         type: Type,
         color: Color,
         timezone: String,
         selfSufficient: DiffType?) {
        self.init(
                id: id,
                name: name,
                unit: unit,
                typeAsString: type.asString,
                colorAsString: color.asString,
                timezone: timezone,
                selfSufficientAsString: selfSufficient?.asString)
    }

    var description: String {
        let sf = selfSufficient ?? ""
        return """
               id = \(id),
               name = \(name),
               unit = \(unit),
               type = \(type),
               color = \(color),
               timezone = \(timezone),
               selfSufficient = \(sf),
               """
    }
}

struct CreateGraphRequest: Request {

    typealias RESPONSE = PixelaResponse
    typealias BODY = CreateGraph

    private let pixela: Pixela
    private let createGraph: CreateGraph

    init(pixela: Pixela, createGraph: CreateGraph) {
        self.pixela = pixela
        self.createGraph = createGraph
    }

    var path: String {
        return "/v1/users/\(pixela.username)/graphs"
    }

    let httpMethod: HttpMethod = .post

    var userToken: String? {
        return pixela.token
    }

    func body() -> CreateGraph? {
        return createGraph
    }

    func responseType() -> PixelaResponse.Type {
        return PixelaResponse.self
    }

    var description: String {
        return """
               POST \(path)
               \(createGraph)
               """
    }
}

public enum Type {
    case int
    case float

    var asString: String {
        switch self {
        case .int: return "int"
        case .float: return "float"
        }
    }
}

public enum Color {
    case shibafu
    case momiji
    case sora
    case ichou
    case ajisai
    case kuro

    var asString: String {
        switch self {
        case .shibafu: return "shibafu"
        case .momiji: return "momiji"
        case .sora: return "sora"
        case .ichou: return "ichou"
        case .ajisai: return "ajisai"
        case .kuro: return "kuro"
        }
    }
}

public enum DiffType {
    case increment
    case decrement

    var asString: String {
        switch self {
        case .increment: return "increment"
        case .decrement: return "decrement"
        }
    }
}
