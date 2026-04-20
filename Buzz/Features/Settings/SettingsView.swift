import SwiftUI

/// App Store guideline 5.1.1(v) requires in-app account deletion. This view exposes it
/// plus notification prefs, free-food alerts toggle, visibility, legal links, sign out.
struct SettingsView: View {
    @Environment(AppServices.self) private var services
    @Environment(AuthSession.self) private var auth
    @State private var freeFoodAlerts = true
    @State private var friendActivityAlerts = true
    @State private var weeklyDigest = true
    @State private var showingDelete = false

    var body: some View {
        NavigationStack {
            List {
                Section("Notifications") {
                    Toggle("Free food alerts", isOn: $freeFoodAlerts)
                    Toggle("Friends RSVP to events", isOn: $friendActivityAlerts)
                    Toggle("Morning digest", isOn: $weeklyDigest)
                }
                .listRowBackground(BuzzColor.surface)

                Section("Privacy") {
                    NavigationLink("Blocked users") { Text("—").foregroundStyle(BuzzColor.textTertiary) }
                    NavigationLink("Download my data") { Text("—").foregroundStyle(BuzzColor.textTertiary) }
                }
                .listRowBackground(BuzzColor.surface)

                Section("Legal") {
                    Link("Privacy Policy", destination: URL(string: "https://buzz.app/legal/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://buzz.app/legal/terms")!)
                    Link("Support", destination: URL(string: "https://buzz.app/support")!)
                }
                .listRowBackground(BuzzColor.surface)

                Section("Account") {
                    Button(role: .none) {
                        Haptics.warning()
                        auth.signOut()
                    } label: {
                        Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(BuzzColor.textPrimary)
                    }
                    Button(role: .destructive) {
                        Haptics.heavy()
                        showingDelete = true
                    } label: {
                        Label("Delete account", systemImage: "trash.fill")
                    }
                }
                .listRowBackground(BuzzColor.surface)

                Section {
                    Text("Buzz v0.1.0 · Built at a US college for US colleges.")
                        .font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textTertiary)
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .iosNavigationInline()
            .sheet(isPresented: $showingDelete) {
                AccountDeletionSheet()
                    .iosDragIndicator()
                    .presentationBackground(.ultraThinMaterial)
            }
        }
    }
}
