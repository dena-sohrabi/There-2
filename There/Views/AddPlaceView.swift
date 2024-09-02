import CoreLocation
import MapKit
import SwiftUI

struct AddPlaceView: View {
    @ObservedObject var viewModel: TimeZoneViewModel
    @StateObject private var searchCompleter = SearchCompleter()
    @State private var cityInput = ""
    @State private var nameInput = ""
    @State private var selectedPlace: CLPlacemark?
    @State private var selectedTimeZone: TimeZone = TimeZone.current
    @State private var isSearching = false
    @Environment(\.dismiss) private var dismiss

    private let geocoder = CLGeocoder()

    var body: some View {
        Form {
            VStack(alignment: .leading) {
                TextField("Name", text: $nameInput)
                TextField("City", text: $cityInput)
                    .onChange(of: cityInput) { newValue in
                        searchCompleter.search(newValue)
                    }

                if !searchCompleter.results.isEmpty {
                    List(searchCompleter.results, id: \.self) { result in
                        Text(result.title)
                            .onTapGesture {
                                cityInput = result.title
                                searchPlace(result)
                            }
                    }
                    .frame(height: min(CGFloat(searchCompleter.results.count) * 44, 200))
                }
            }

            if isSearching {
                ProgressView()
            }

            if let place = selectedPlace {
                Text("Country: \(place.country ?? "Unknown")")
                if let countryCode = place.isoCountryCode {
                    Text(String(countryCode.unicodeScalars.map { Character(UnicodeScalar(127397 + $0.value)!) }))
                }
            }

            Picker("Time Zone", selection: $selectedTimeZone) {
                ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { identifier in
                    Text(identifier)
                        .tag(TimeZone(identifier: identifier)!)
                }
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Button("Add Place") {
                    addPlace()
                }
                .disabled(selectedPlace == nil)
            }
        }
        .padding()
        .frame(width: 300, height: 400)
    }

    private func searchPlace(_ result: MKLocalSearchCompletion) {
        isSearching = true

        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, _ in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                isSearching = false
                return
            }

            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                DispatchQueue.main.async {
                    isSearching = false
                    if let placemark = placemarks?.first {
                        self.selectedPlace = placemark
                        if let timeZone = placemark.timeZone {
                            self.selectedTimeZone = timeZone
                        }
                    }
                }
            }
        }
    }

    private func addPlace() {
        guard let place = selectedPlace,
              let city = place.locality ?? place.name,
              let country = place.country,
              let countryCode = place.isoCountryCode else { return }

        let flagImage = saveFlagImage(for: countryCode)
        viewModel.addPlace(place: Place(
            id: UUID(),
            name: nameInput,
            city: city,
            country: country,
            countryCode: countryCode,
            timeZoneIdentifier: selectedTimeZone.identifier,
            flagImagePath: flagImage
        ))
        dismiss()
    }

    private func saveFlagImage(for countryCode: String) -> String? {
        let flag = String(countryCode.unicodeScalars.map { Character(UnicodeScalar(127397 + $0.value)!) })
        let image = NSImage(size: NSSize(width: 100, height: 100), flipped: false) { rect in
            NSColor.clear.set()
            rect.fill()
            flag.draw(in: rect, withAttributes: [.font: NSFont.systemFont(ofSize: 80)])
            return true
        }
        return saveImage(image)
    }

    private func saveImage(_ image: NSImage) -> String? {
        guard let data = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }

        let fileName = "\(UUID().uuidString).png"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)

        do {
            try pngData.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}

class SearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKLocalSearchCompletion] = []
    private let completer: MKLocalSearchCompleter

    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    func search(_ query: String) {
        completer.queryFragment = query
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
