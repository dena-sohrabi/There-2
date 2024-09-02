import Foundation

class TimeZoneManager {
    static let shared = TimeZoneManager()

    private init() {}

    func getTimeForTimeZone(_ timeZoneIdentifier: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        return formatter.string(from: Date())
    }
}
