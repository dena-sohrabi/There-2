import SwiftUI

@main
struct TimeZoneTrackerApp: App {
    @StateObject private var viewModel = TimeZoneViewModel()

    var body: some Scene {
        MenuBarExtra("Time Zones", systemImage: "clock") {
            if UserDefaults.standard.bool(forKey: "hasCompletedInitialSetup") {
                ContentView(viewModel: viewModel)
                    .background {
                        Color(.quinarySystemFill)
                            .ignoresSafeArea()
                    }
            } else {
                InitialSetupView(viewModel: viewModel)
            }
        }
        .windowStyle(.plain)
        .menuBarExtraStyle(.window)
        .windowIdealSize(.fitToContent)

        Window("Add Person", id: "add-person") {
            AddTimeZoneView(viewModel: viewModel)
        }
        .windowStyle(.hiddenTitleBar)
        .windowIdealSize(.fitToContent)
        
        Window("Add Place", id: "add-place") {
            AddPlaceView(viewModel: viewModel)
        }
        .windowStyle(.hiddenTitleBar)
        .windowIdealSize(.fitToContent)

        Window("Setup", id: "setup") {
            InitialSetupView(viewModel: viewModel)
        }
        .windowStyle(.hiddenTitleBar)
        .windowIdealSize(.fitToContent)
    }
}
