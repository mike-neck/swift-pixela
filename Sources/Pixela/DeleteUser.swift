import Foundation

struct DeleteUser: Codable, CustomStringConvertible {
    var description: String {
        return "delete-user"
    }
}

struct DeleteUserRequest: Request {

    private let pixela: Pixela

    init(pixela: Pixela) {
        self.pixela = pixela
    }

    var path: String {
        return "/v1/users/\(pixela.username)"
    }

    let httpMethod: HttpMethod = .delete

    var userToken: String? {
        return pixela.token
    }

    func body() -> DeleteUser? {
        return nil
    }

    func responseType() -> PixelaResponse.Type {
        return PixelaResponse.self
    }

    typealias RESPONSE = PixelaResponse
    typealias BODY = DeleteUser

    var description: String {
        return """
               DELETE \(path)
               """
    }
}
