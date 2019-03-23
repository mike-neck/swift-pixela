import Foundation

struct CreateUser: Codable, CustomStringConvertible {
    let token: String
    let username: String

    let agreeTermsOfService: String

    let notMinor: String

    init(token: String, username: String, agreeTermsOfService: Answer, notMinor: Answer) {
        self.token = token
        self.username = username
        self.agreeTermsOfService = agreeTermsOfService.asString
        self.notMinor = notMinor.asString
    }

    public var description: String {
        return """
               [token=\(token),username=\(username),agreeTermsOfService=\(agreeTermsOfService),notMinor=\(notMinor)]
               """
    }
}

struct CreateUserRequest: Request {

    typealias RESPONSE = PixelaResponse
    typealias BODY = CreateUser

    let path: String = "/v1/users"
    let httpMethod: HttpMethod = .post
    let userToken: String? = nil

    func body() -> CreateUser? {
        return createUser
    }

    func responseType() -> PixelaResponse.Type {
        return PixelaResponse.self
    }

    let createUser: CreateUser

    init(createUser: CreateUser) {
        self.createUser = createUser
    }

    init(
            token: String,
            username: String,
            agreeTermsOfService: Answer,
            notMinor: Answer) {
        self.init(
                createUser: CreateUser(
                        token: token,
                        username: username,
                        agreeTermsOfService: agreeTermsOfService,
                        notMinor: notMinor))
    }

    public var description: String {
        return """
               POST \(path)
               \(createUser)
               """
    }
}
