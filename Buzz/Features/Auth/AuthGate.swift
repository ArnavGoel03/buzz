import SwiftUI

/// Wraps a primary action (e.g. "RSVP", "Invite member") that requires sign-in. Guests
/// tapping it see the SignInSheet; authenticated users pass through. Keeps each caller
/// from duplicating the "are we signed in?" boilerplate.
struct AuthGate<Label: View>: View {
    @Environment(AuthSession.self) private var auth
    @State private var showingSignIn = false
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button {
            if auth.isAuthenticated {
                action()
            } else {
                Haptics.tap()
                showingSignIn = true
            }
        } label: {
            label()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingSignIn) {
            SignInSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
    }
}
