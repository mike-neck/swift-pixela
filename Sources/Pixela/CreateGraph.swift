import Foundation

struct CreateGraph: Codable, CustomStringConvertible {

    let id: String
    let name: String
    let unit: String
    let type: String
    let color: String
    let timezone: String?
    let selfSufficient: String?

    private init(id: String,
                 name: String,
                 unit: String,
                 typeAsString: String,
                 colorAsString: String,
                 timezone: String?,
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
         timezone: String?,
         selfSufficient: Diff?) {
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
        let tz = timezone ?? ""
        let sf = selfSufficient ?? ""
        return """
               id = \(id),
               name = \(name),
               unit = \(unit),
               type = \(type),
               color = \(color),
               timezone = \(tz),
               selfSufficient = \(sf),
               """
    }
}

enum Type {
    case int
    case float

    var asString: String {
        switch self {
        case .int: return "int"
        case .float: return "float"
        }
    }
}

enum Color {
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

enum Diff {
    case increment
    case decrement

    var asString: String {
        switch self {
        case .increment: return "increment"
        case .decrement: return "decrement"
        }
    }
}
