import Foundation

struct TimeZoneEntry: Identifiable, Codable {
    let id: UUID
    let name: String
    let city: String
    let country: String
    let timeZoneIdentifier: String
    let photoPath: String?
    
    init(id: UUID = UUID(), name: String, city: String, country: String, timeZoneIdentifier: String, photoPath: String? = nil) {
        self.id = id
        self.name = name
        self.city = city
        self.country = country
        self.timeZoneIdentifier = timeZoneIdentifier
        self.photoPath = photoPath
    }
    
    func timeDifference(from userTimeZone: TimeZone) -> String {
        let userOffset = userTimeZone.secondsFromGMT()
        guard let entryTimeZone = TimeZone(identifier: timeZoneIdentifier) else {
            return "Unknown"
        }
        let entryOffset = entryTimeZone.secondsFromGMT()
        let difference = (entryOffset - userOffset) / 3600
        
        if difference == 0 {
            return "Same time"
        } else if difference > 0 {
            return "+\(difference)h"
        } else {
            return "\(difference)h"
        }
    }
}
