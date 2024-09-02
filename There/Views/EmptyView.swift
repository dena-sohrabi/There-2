import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
                Image(systemName: "person.badge.clock")
                    .font(.title2)
                    .foregroundColor(.blue)
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.pink)
            }

            Text("Add a Place or a Person to start")
                .fontWeight(.medium)
                .font(.title)
                .padding()
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    EmptyView()
}
