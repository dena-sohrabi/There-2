import Bodega
import Foundation

class BodegaStore {
    static let shared = BodegaStore()

    private let storage: DiskStorageEngine

    private init() {
//        do {
        storage = DiskStorageEngine(
            directory: .sharedContainer(forAppGroupIdentifier: Constants.appGroupIdentifier, appendingPath: "There")
        )
//        } catch {
//            fatalError("Failed to initialize Bodega storage: \(error)")
//        }
    }

    func saveUserInfo(_ userInfo: UserInfo) {
        Task {
            do {
                let data = try JSONEncoder().encode(userInfo)
                let cacheKey = CacheKey("userInfo")
                try await storage.write(data, key: cacheKey)
            } catch {
                print("Error saving user info: \(error)")
            }
        }
    }

    func loadUserInfo() async -> UserInfo? {
        let cacheKey = CacheKey("userInfo")

        do {
            if let data = await storage.read(key: cacheKey) {
                return try JSONDecoder().decode(UserInfo.self, from: data)
            }
        } catch {
            print("Error loading user info: \(error)")
        }

        return nil
    }

    func saveTimeZones(_ timeZones: [TimeZoneEntry]) {
        Task {
            do {
                let data = try JSONEncoder().encode(timeZones)
                let cacheKey = CacheKey("timeZones")
                try await storage.write(data, key: cacheKey)
            } catch {
                print("Error saving time zones: \(error)")
            }
        }
    }

    func savePlaces(_ places: [Place]) {
        Task {
            do {
                let data = try JSONEncoder().encode(places)
                let cacheKey = CacheKey("places")
                try await storage.write(data, key: cacheKey)
            } catch {
                print("Error saving time zones: \(error)")
            }
        }
    }

    func loadTimeZones() async -> [TimeZoneEntry] {
        let cacheKey = CacheKey("timeZones")
        do {
            if let data = try await storage.read(key: cacheKey) {
                return try JSONDecoder().decode([TimeZoneEntry].self, from: data)
            }
        } catch {
            print("Error loading time zones: \(error)")
        }
        return []
    }

    func loadPlaces() async -> [Place] {
        let cacheKey = CacheKey("places")
        do {
            if let data = try await storage.read(key: cacheKey) {
                return try JSONDecoder().decode([Place].self, from: data)
            }
        } catch {
            print("Error loading time zones: \(error)")
        }
        return []
    }
}
