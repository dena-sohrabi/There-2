import SwiftUI

struct InitialSetupView: View {
    @ObservedObject var viewModel: TimeZoneViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var currentTimeZone = TimeZone.current

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Email", text: $email)
            Text("Your Time Zone: \(currentTimeZone.identifier)")

            HStack {
                Button("Skip") {
                    Task {
                        await viewModel.skipInitialSetup()
                    }
                    UserDefaults.standard.set(true, forKey: "hasCompletedInitialSetup")
                }
                Spacer()
                Button("Save") {
                    Task {
                        await viewModel.saveUserInfo(name: name, email: email, timeZone: currentTimeZone)
                    }
                    UserDefaults.standard.set(true, forKey: "hasCompletedInitialSetup")
                }
                .disabled(name.isEmpty || email.isEmpty)
            }
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}
