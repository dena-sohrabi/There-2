import SwiftUI

struct PlaceRowView: View {
    let place: Place
    let userTimeZone: TimeZone
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            if let photoPath = place.flagImagePath, let image = NSImage(contentsOfFile: photoPath) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading) {
                Text(place.name)
                    .font(.headline)
                Text("\(place.city), \(place.country)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                HStack {
                    timeIcon
                        .help(timeOfDayDescription)

                    Text(formattedTime)
                        .font(.title2)
                        .monospacedDigit()
                        .contentTransition(.interpolate)
                }
                Text(place.timeDifference(from: userTimeZone))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onReceive(timer) { _ in
            updateTime()
        }
        .onAppear(perform: updateTime)
    }

    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: place.timeZoneIdentifier)
        currentTime = Date()
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: place.timeZoneIdentifier)
        return formatter.string(from: currentTime)
    }

    private var timeIcon: some View {
        let timeZone = TimeZone(identifier: place.timeZoneIdentifier) ?? .current
        let hour = Calendar.current.component(.hour, from: currentTime.convertToTimeZone(timeZone))
        let iconName: String

        switch hour {
        case 5 ..< 12:
            iconName = "sun.and.horizon"
        case 12 ..< 17:
            iconName = "sun.max"
        case 17 ..< 21:
            iconName = "sun.dust"
        default:
            iconName = "moon.stars"
        }

        return Image(systemName: iconName)
    }

    private var timeOfDayDescription: String {
        let timeZone = TimeZone(identifier: place.timeZoneIdentifier) ?? .current
        let hour = Calendar.current.component(.hour, from: currentTime.convertToTimeZone(timeZone))

        switch hour {
        case 5 ..< 12:
            return "Morning"
        case 12 ..< 17:
            return "Afternoon"
        case 17 ..< 21:
            return "Evening"
        default:
            return "Night"
        }
    }
}
