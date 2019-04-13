import Foundation

struct GetGraphDefinitions: Codable, CustomStringConvertible {

    var description: String {
        return """

               """
    }
}

struct GetGraphDefinitionsRequest: Request {

    typealias RESPONSE = RawGraphDefinitions

    typealias BODY = GetGraphDefinitions

    let pixela: Pixela

    init(pixela: Pixela) {
        self.pixela = pixela
    }

    func body() -> GetGraphDefinitions? {
        return nil
    }

    func responseType() -> RawGraphDefinitions.Type {
        return RawGraphDefinitions.self
    }

    var path: String {
        return "/v1/users/\(pixela.username)/graphs"
    }

    var httpMethod: HttpMethod {
        return .get
    }

    var userToken: String? {
        return pixela.token
    }

    var description: String {
        return """
               GET \(path)
               """
    }
}
