//
// Created by mike on 2019-03-22.
//

import Foundation

public struct PixelaResponse: Decodable, CustomStringConvertible {

    public var isSuccess: Bool
    public var message: String
    public var description: String {
        get {
            return """
                   [success:\(isSuccess),message:"\(message)"]
                   """
        }
    }

    init(isSuccess: Bool, message: String) {
        self.isSuccess = isSuccess
        self.message = message
    }

    init() {
        self.isSuccess = false
        self.message = ""
    }
}
