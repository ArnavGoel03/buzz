import SwiftUI

/// App Clip entry point. Apple's instant-experience module: < 10MB binary, runs from a
/// QR/NFC tap or AirDrop without requiring full app install. Shows the org preview and
/// upsells "Get the full Buzz app" via SKOverlay.
///
/// Production: configure via Apple Developer → Identifiers → Add an App Clip; add an
/// `apple-app-site-association` file at https://buzz.app/.well-known/ to bind URLs to
/// the clip; declare the clip target in `project.yml`.
@main
struct BuzzAppClip: App {
    var body: some Scene {
        WindowGroup {
            AppClipRootView()
                .preferredColorScheme(.dark)
        }
    }
}

struct AppClipRootView: View {
    @State private var url: URL?
    @State private var showInstallPrompt = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.yellow)
                Text("Buzz")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text("Save this club + see today's events.\nNo download needed.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.75))
                Button {
                    showInstallPrompt = true
                } label: {
                    Text("Get the full app")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(.yellow))
                }
            }
            .padding(40)
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            url = activity.webpageURL
        }
    }
}
