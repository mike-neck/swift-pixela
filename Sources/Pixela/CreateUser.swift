import Foundation

struct CreateUser: Codable {
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
}
