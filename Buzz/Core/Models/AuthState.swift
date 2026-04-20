import Foundation

/// App-wide auth state. Guests can browse the map and discover clubs; personalized actions
/// (RSVP, profile, org admin) route through AuthGate which prompts sign-in only when needed.
/// This is the frictionless core: experience the value first, commit second.
enum AuthState: Sendable, Equatable {
    case guest                           // browsing without an account
    case onboarding                      // SIWA complete but profile not set up
    case authenticated(profileID: UUID)
}
