import SwiftUI

struct TimeZoneRowView: View {
    let entry: TimeZoneEntry
    let userTimeZone: TimeZone
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            if let photoPath = entry.photoPath, let image = NSImage(contentsOfFile: photoPath) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
            }

            VStack(alignment: .leading) {
                Text(entry.name)
                    .font(.headline)
                Text("\(entry.city), \(entry.country)")
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
                        .contentTransition(.numericText())
                }
                Text(entry.timeDifference(from: userTimeZone))
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
        formatter.timeZone = TimeZone(identifier: entry.timeZoneIdentifier)
        currentTime = Date()
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: entry.timeZoneIdentifier)
        return formatter.string(from: currentTime)
    }

    private var timeIcon: some View {
        let timeZone = TimeZone(identifier: entry.timeZoneIdentifier) ?? .current
        let hour = Calendar.current.component(.hour, from: currentTime.convertToTimeZone(timeZone))
        let iconName: String

        switch hour {
        case 5 ..< 8:
            iconName = "Early Morning"
        case 8 ..< 12:
            iconName = "Morning"
        case 12 ..< 3:
            iconName = "Early Afternoon"
        case 3 ..< 6:
            iconName = "Late Afternoon"
        case 6 ..< 8:
            iconName = "Early Evening"
        case 8 ..< 10:
            iconName = "Evening"
        case 10 ..< 12:
            iconName = "Night"
        default:
            iconName = "Night"
        }

        return Image(systemName: iconName)
    }

    private var timeOfDayDescription: String {
        let timeZone = TimeZone(identifier: entry.timeZoneIdentifier) ?? .current
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

extension Date {
    func convertToTimeZone(_ timeZone: TimeZone) -> Date {
        let sourceOffset = TimeZone.current.secondsFromGMT(for: self)
        let destinationOffset = timeZone.secondsFromGMT(for: self)
        let timeInterval = TimeInterval(destinationOffset - sourceOffset)
        return addingTimeInterval(timeInterval)
    }
}
