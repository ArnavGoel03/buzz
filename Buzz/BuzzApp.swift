import SwiftUI

@main
struct BuzzApp: App {
    @State private var services = AppServices()
    @State private var auth = AuthSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(services)
                .environment(auth)
                .preferredColorScheme(.dark)
        }
    }
}
