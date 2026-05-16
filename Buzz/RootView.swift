import SwiftUI

struct RootView: View {
    @Environment(AppServices.self) private var services
    @Environment(AuthSession.self) private var auth
    @Environment(\.horizontalSizeClass) private var hSize
    @State private var selection: Tab = .live
    @State private var splashDone = false
    @State private var showingQuickSwitcher = false
    #if os(macOS)
    @Environment(\.openSettings) private var openSettings
    #endif

    enum Tab: Hashable, Identifiable, CaseIterable {
        case live, map, clubs, profile
        var id: Self { self }
        var label: String {
            switch self {
            case .live: "Live"; case .map: "Map"
            case .clubs: "Clubs"; case .profile: "Profile"
            }
        }
        var icon: String {
            switch self {
            case .live: "flame.fill"; case .map: "map.fill"
            case .clubs: "person.3.fill"; case .profile: "person.crop.circle.fill"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            content
            if !services.network.isOnline {
                OfflineBanner().zIndex(1)
            }
            if !splashDone {
                SplashView(onFinish: {
                    withAnimation(.smooth(duration: 0.5)) { splashDone = true }
                })
                .transition(.opacity).zIndex(2)
            }
        }
        .animation(.snappy(duration: 0.25), value: services.network.isOnline)
        .privacyScreen()
        // Rule §3: ⌘K opens the quick switcher.
        .keyboardShortcut("k", modifiers: .command)
        .sheet(isPresented: $showingQuickSwitcher) {
            QuickSwitcherSheet(selection: $selection, isPresented: $showingQuickSwitcher)
        }
        .task {
            services.location.requestWhenInUse()
        }
        .onChange(of: selection) { _, _ in Haptics.selection() }
        .onChange(of: auth.currentProfileID) { _, _ in services.resetForAccountSwitch() }
    }

    @ViewBuilder
    private var content: some View {
        switch auth.state {
        case .guest, .authenticated: adaptiveLayout
        case .onboarding: OnboardingView().transition(.opacity)
        }
    }

    @ViewBuilder
    private var adaptiveLayout: some View {
        #if os(macOS)
        sidebar
        #else
        if hSize == .regular { sidebar } else { tabs }
        #endif
    }

    private var sidebar: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(Tab.allCases, selection: $selection) { tab in
                    Label(tab.label, systemImage: tab.icon).tag(tab)
                }
                .navigationTitle("Buzz")
                // Rule §3: always-visible version footer + gear-to-Settings.
                versionFooter
            }
        } detail: {
            destinationView(for: selection)
        }
        .tint(BuzzColor.accent)
    }

    private var versionFooter: some View {
        HStack {
            Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0")")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textTertiary)
            Spacer()
            Button {
                #if os(macOS)
                openSettings()
                #endif
            } label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(BuzzColor.textSecondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var tabs: some View {
        TabView(selection: $selection) {
            LiveNowView().tabItem { Label("Live", systemImage: "flame.fill") }.tag(Tab.live)
            MapView().tabItem { Label("Map", systemImage: "map.fill") }.tag(Tab.map)
            ClubsView().tabItem { Label("Clubs", systemImage: "person.3.fill") }.tag(Tab.clubs)
            ProfileView().tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }.tag(Tab.profile)
        }
        .tint(BuzzColor.accent)
    }

    @ViewBuilder
    private func destinationView(for tab: Tab) -> some View {
        switch tab {
        case .live: LiveNowView()
        case .map: MapView()
        case .clubs: ClubsView()
        case .profile: ProfileView()
        }
    }
}

/// Rule §3: ⌘K fuzzy-find across panes + common commands.
private struct QuickSwitcherSheet: View {
    @Binding var selection: RootView.Tab
    @Binding var isPresented: Bool
    @State private var query = ""

    private var filtered: [RootView.Tab] {
        if query.isEmpty { return RootView.Tab.allCases }
        return RootView.Tab.allCases.filter {
            $0.label.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { tab in
                Button {
                    selection = tab
                    isPresented = false
                } label: {
                    Label(tab.label, systemImage: tab.icon)
                }
            }
            .searchable(text: $query, prompt: "Jump to…")
            .navigationTitle("Switch")
        }
        .presentationDetents([.medium])
    }
}
