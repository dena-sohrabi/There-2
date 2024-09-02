import Contacts
import CoreLocation
import Foundation

struct Place: Codable, Identifiable {
    let id: UUID
    let name: String
    let city: String
    let country: String
    let countryCode: String
    let timeZoneIdentifier: String
    let flagImagePath: String?

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

import Foundation

struct Country: Codable {
    let name: String
    let code: String
}

class PlaceService {
    private var countries: [Country] = []

    init() {
        loadCountries()
    }

    private func loadCountries() {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load countries.json")
            return
        }

        do {
            countries = try JSONDecoder().decode([Country].self, from: data)
        } catch {
            print("Failed to decode countries: \(error)")
        }
    }

    func getCountryFlag(countryCode: String) -> String {
        let base: UInt32 = 127397
        var flagString = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let scalar = UnicodeScalar(base + scalar.value) {
                flagString.append(String(scalar))
            }
        }
        return flagString
    }

    func getCountryCode(for country: String) -> String {
        if let matchedCountry = countries.first(where: { $0.name.lowercased() == country.lowercased() }) {
            return matchedCountry.code
        }
        return "Unknown"
    }

    func getCountryName(for code: String) -> String {
        if let matchedCountry = countries.first(where: { $0.code.lowercased() == code.lowercased() }) {
            return matchedCountry.name
        }
        return "Unknown"
    }

    func getAllCountries() -> [Country] {
        return countries
    }
}
