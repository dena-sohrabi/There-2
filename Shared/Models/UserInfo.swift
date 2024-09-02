import Foundation

struct UserInfo: Codable {
    let name: String
    let email: String
    let timeZoneIdentifier: String

    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }
}
