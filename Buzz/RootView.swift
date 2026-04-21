import SwiftUI

struct RootView: View {
    @Environment(AppServices.self) private var services
    @Environment(AuthSession.self) private var auth
    @State private var selection: Tab = .live
    @State private var splashDone = false

    enum Tab: Hashable { case live, map, clubs, profile }

    var body: some View {
        ZStack(alignment: .top) {
            content
            if !services.network.isOnline {
                OfflineBanner()
                    .zIndex(1)
            }
            if !splashDone {
                SplashView(onFinish: {
                    withAnimation(.smooth(duration: 0.5)) { splashDone = true }
                })
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .animation(.snappy(duration: 0.25), value: services.network.isOnline)
        .privacyScreen()
        .task {
            services.location.requestWhenInUse()
        }
        .onChange(of: selection) { _, _ in
            Haptics.selection()
        }
        // VULN #82 patch: rebuild repos on auth identity change so the next user never
        // sees the previous user's cached events / orgs / profile.
        .onChange(of: auth.currentProfileID) { _, _ in
            services.resetForAccountSwitch()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch auth.state {
        case .guest, .authenticated:
            tabs
        case .onboarding:
            OnboardingView()
                .transition(.opacity)
        }
    }

    private var tabs: some View {
        TabView(selection: $selection) {
            LiveNowView()
                .tabItem { Label("Live", systemImage: "flame.fill") }
                .tag(Tab.live)
            MapView()
                .tabItem { Label("Map", systemImage: "map.fill") }
                .tag(Tab.map)
            ClubsView()
                .tabItem { Label("Clubs", systemImage: "person.3.fill") }
                .tag(Tab.clubs)
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(Tab.profile)
        }
        .tint(BuzzColor.accent)
    }
}
