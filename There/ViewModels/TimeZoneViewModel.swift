import Combine
import Foundation

@MainActor
class TimeZoneViewModel: ObservableObject {
    @Published private(set) var timeZoneEntries: [TimeZoneEntry] = []
    @Published private(set) var places: [Place] = []
    @Published private(set) var userInfo: UserInfo?
    private let store = BodegaStore.shared

    init() {
        Task {
            await loadUserInfo()
            await loadTimeZones()
            await loadPlaces()
        }
    }

    func loadUserInfo() async {
        userInfo = await store.loadUserInfo()
    }

    func loadTimeZones() async {
        timeZoneEntries = await store.loadTimeZones()
    }

    func loadPlaces() async {
        places = await store.loadPlaces()
    }

    func saveUserInfo(name: String, email: String, timeZone: TimeZone) async {
        let newUserInfo = UserInfo(name: name, email: email, timeZoneIdentifier: timeZone.identifier)
        await store.saveUserInfo(newUserInfo)
        userInfo = newUserInfo
    }

    func skipInitialSetup() async {
        let defaultUserInfo = UserInfo(name: "User", email: "", timeZoneIdentifier: TimeZone.current.identifier)
        await store.saveUserInfo(defaultUserInfo)
        userInfo = defaultUserInfo
    }

    func addTimeZone(name: String, city: String, country: String, countryCode: String, timeZoneIdentifier: String, photoPath: String?) {
        let newEntry = TimeZoneEntry(name: name, city: city, country: country, timeZoneIdentifier: timeZoneIdentifier, photoPath: photoPath)
        timeZoneEntries.append(newEntry)
        Task {
            await saveTimeZones()
        }
    }

    func addPlace(place: Place) {
        places.append(place)
        Task {
             savePlaces()
        }
    }

    func deleteTimeZone(_ timeZone: TimeZoneEntry) {
        timeZoneEntries.removeAll { $0.id == timeZone.id }
        Task {
             saveTimeZones()
        }
    }

    func deletePlace(_ place: Place) {
        DispatchQueue.main.async {
            self.places.removeAll { place in
                place.id == place.id
            }
        }
        Task {
             savePlaces()
        }
    }

    func deleteAll() {
        places.removeAll()
        timeZoneEntries.removeAll()
        Task {
            saveTimeZones()
            savePlaces()
        }
    }

    private func saveTimeZones() {
        store.saveTimeZones(timeZoneEntries)
    }

    private func savePlaces() {
        store.savePlaces(places)
    }
}
