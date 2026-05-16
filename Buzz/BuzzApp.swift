import SwiftUI
#if os(macOS)
import AppKit
#endif

@main
struct BuzzApp: App {
    init() {
        // Rule §3: single-instance enforcement on macOS. If another Buzz process is
        // already running, activate it and terminate this duplicate so the user can't
        // accidentally launch two windows of the daily-driver app.
        #if os(macOS)
        let bid = Bundle.main.bundleIdentifier ?? "com.arnavgoel.buzz"
        let others = NSRunningApplication.runningApplications(withBundleIdentifier: bid)
            .filter { $0 != NSRunningApplication.current }
        if let existing = others.first {
            existing.activate(options: [.activateAllWindows])
            NSApp.terminate(nil)
        }
        #endif
    }

    // Rule §1: `@State` defaults run on the main actor at view-init. `AppServices()`
    // does synchronous Bundle reads (mock JSON decode). Optional + populated in
    // `.task {}` keeps the splash on-screen instead of janking cold launch.
    @State private var services: AppServices?
    @State private var auth = AuthSession()

    var body: some Scene {
        WindowGroup {
            Group {
                if let services {
                    RootView()
                        .environment(services)
                        .environment(auth)
                } else {
                    SplashView { }
                        .environment(auth)
                }
            }
            #if os(iOS)
            .preferredColorScheme(.dark)
            #endif
            .task {
                if services == nil {
                    services = await Task.detached(priority: .userInitiated) {
                        await MainActor.run { AppServices() }
                    }.value
                }
            }
        }
        #if os(macOS)
        .defaultSize(width: 1024, height: 768)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(after: .appInfo) {
                Link("Check for Updates…", destination: URL(string: "https://buzz.app/releases")!)
            }
            CommandMenu("Help") {
                Link("Website", destination: URL(string: "https://buzz.app")!)
                Link("Send Feedback", destination: URL(string: "mailto:hi@buzz.app")!)
                Link("Privacy", destination: URL(string: "https://buzz.app/legal/privacy")!)
            }
        }

        // Rule §3: macOS Settings live in a proper `Settings { }` scene (⌘,), not a tab.
        Settings {
            if let services {
                SettingsView()
                    .environment(services)
                    .environment(auth)
                    .frame(width: 520, height: 600)
            } else {
                ProgressView().frame(width: 520, height: 600)
            }
        }
        #endif
    }
}
