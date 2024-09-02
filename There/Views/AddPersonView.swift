import CoreLocation
import MapKit
import SwiftUI

struct AddTimeZoneView: View {
    @ObservedObject var viewModel: TimeZoneViewModel
    @StateObject private var searchCompleter = SearchCompleter()
    @State private var name = ""
    @State private var cityInput = ""
    @State private var selectedPlace: CLPlacemark?
    @State private var selectedTimeZone: TimeZone = TimeZone.current
    @State private var selectedImage: NSImage?
    @State private var isSearching = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("Name", text: $name)

            VStack(alignment: .leading) {
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
            }

            Picker("Time Zone", selection: $selectedTimeZone) {
                ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { identifier in
                    Text(identifier)
                        .tag(TimeZone(identifier: identifier)!)
                }
            }

            Button("Select Photo") {
                selectPhoto()
            }

            if let image = selectedImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Button("Add") {
                    addTimeZone()
                }
                .disabled(name.isEmpty || selectedPlace == nil)
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
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
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

    private func addTimeZone() {
        guard let place = selectedPlace,
              let city = place.locality ?? place.name,
              let country = place.country,
              let countryCode = place.isoCountryCode else { return }

        let photoPath = selectedImage.flatMap(saveImage)

        viewModel.addTimeZone(name: name, city: city, country: country, countryCode: countryCode, timeZoneIdentifier: selectedTimeZone.identifier, photoPath: photoPath)
        dismiss()
    }

    private func selectPhoto() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]

        panel.begin { response in
            if response == .OK, let url = panel.url {
                if let image = NSImage(contentsOf: url) {
                    self.selectedImage = image
                }
            }
        }
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
