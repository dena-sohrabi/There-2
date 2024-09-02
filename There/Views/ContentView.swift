import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: TimeZoneViewModel
    @State private var showingAddSheet = false
    @Environment(\.openWindow) var openWindow

    var body: some View {
        VStack {
            if viewModel.timeZoneEntries.isEmpty && viewModel.places.isEmpty {
                EmptyView()
            } else {
                List {
                    Section(header: Text("People")) {
                        ForEach(viewModel.timeZoneEntries) { entry in
                            TimeZoneRowView(entry: entry, userTimeZone: viewModel.userInfo?.timeZone ?? .current)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteTimeZone(entry)
                                    } label: {
                                        Label("Delete Person", systemImage: "trash")
                                    }
                                }
                        }
                    }

                    Section(header: Text("Places")) {
                        ForEach(viewModel.places) { place in
                            PlaceRowView(place: place, userTimeZone: viewModel.userInfo?.timeZone ?? .current)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deletePlace(place)
                                    } label: {
                                        Label("Delete Place", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            }
        }
        .frame(minHeight: 300)
        .frame(height: 400)
//        .overlay(alignment: .bottom) {
        .safeAreaInset(edge: .bottom) {
            if let userInfo = viewModel.userInfo {
                HStack(alignment: .center) {
                    Circle()
                        .fill(.gray)
                        .frame(width: 25)
                    VStack(alignment: .leading) {
                        Text(userInfo.name)
                            .bold()
                        Text(userInfo.email)
                    }
                    Spacer()
                    Menu {
                        Button("Add Friend Time Zone") {
                            openWindow(id: "add-person")
                        }
                        Button("Add Place Time Zone") {
                            openWindow(id: "add-place")
                        }
                        Button("Delete All") {
                            viewModel.deleteAll()
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.hidden)
                    .frame(width: 25, height: 25)
                }
                .padding(12)
                .background(.white)
            }
        }
//        }
    }

    private func deleteTimeZones(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteTimeZone(viewModel.timeZoneEntries[index])
        }
    }
}
