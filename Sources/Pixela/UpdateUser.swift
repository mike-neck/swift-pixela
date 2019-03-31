import Foundation

struct UpdateUser: Codable, CustomStringConvertible {
    let newToken: String

    init(newToken: String) {
        self.newToken = newToken
    }

    public var description: String {
        return """
               [newToken=\(newToken)]
               """
    }
}

extension UpdateUser: Equatable {
    public static func ==(lhs: UpdateUser, rhs: UpdateUser) -> Bool {
        return lhs.newToken == rhs.newToken
    }
}

struct UpdateUserRequest: Request {

    typealias RESPONSE = PixelaResponse
    typealias BODY = UpdateUser

    let httpMethod: HttpMethod = .put

    private let pixela: Pixela
    private let updateUser: UpdateUser

    init(pixela: Pixela, newToken: String) {
        self.init(pixela: pixela, UpdateUser(newToken: newToken))
    }

    init(pixela: Pixela, _ updateUser: UpdateUser) {
        self.pixela = pixela
        self.updateUser = updateUser
    }

    public var path: String {
        return "/v1/users/\(pixela.username)"
    }

    public var userToken: String? {
        return pixela.token
    }

    func body() -> UpdateUser? {
        return updateUser
    }

    func responseType() -> PixelaResponse.Type {
        return PixelaResponse.self
    }

    public var description: String {
        return """
               PUT \(path)
               \(updateUser)
               """
    }
}
