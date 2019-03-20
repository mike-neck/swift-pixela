import Foundation

enum Answer {
    case yes
    case no

    var asString: String {
        get {
            switch self {
            case .yes: return "yes"
            case .no:  return "no"
            }
        }
    }
}
