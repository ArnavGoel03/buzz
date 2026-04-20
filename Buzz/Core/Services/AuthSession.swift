import Foundation
import Observation

/// Holds the current AuthState, exposes sign-in stubs that real Supabase / SIWA flows
/// wire into. Guest is the default — no sign-in prompt on launch.
@Observable
@MainActor
final class AuthSession {
    var state: AuthState = .guest

    var isAuthenticated: Bool {
        if case .authenticated = state { return true }
        return false
    }

    var currentProfileID: UUID? {
        if case let .authenticated(id) = state { return id }
        return nil
    }

    // ⚠️  SECURITY — STUB ONLY ⚠️
    // The three methods below jump straight to `.onboarding` for the mock build. In
    // production they MUST call Supabase, which performs SERVER-SIDE verification of the
    // OAuth identity token against Apple/Google JWKS, then mints a Supabase JWT. Never let
    // the client unilaterally claim "I am authenticated." Replacing these stubs without
    // wiring the real flow grants any client the ability to impersonate any account.

    /// SIWA: take `authorizationCode` from `ASAuthorization.appleIDCredential` and call
    /// `supabase.auth.signInWithIdToken(provider: .apple, idToken: ...)`. Supabase verifies
    /// against Apple's JWKS and returns a session.
    func continueWithApple() async {
        state = .onboarding
    }

    /// Same pattern with `provider: .google`.
    func continueWithGoogle() async {
        state = .onboarding
    }

    /// Email OTP: `auth.signInWithOTP(email:)` sends a 6-digit code; `auth.verifyOTP(...)`
    /// exchanges it for a session.
    func continueWithEmail(_ email: String) async {
        state = .onboarding
    }

    /// Called once onboarding collects the minimum (name + campus) and creates the profile.
    func completeOnboarding(profileID: UUID) {
        state = .authenticated(profileID: profileID)
    }

    /// Returning users: jump straight to authenticated if we find a cached session on launch.
    func restoreSession(profileID: UUID) {
        state = .authenticated(profileID: profileID)
    }

    func signOut(purge: (() async -> Void)? = nil) {
        KeychainTokenStore.deleteAll()
        // VULN #57 patch: caller passes a purge closure that clears in-memory caches across
        // services + view models. Otherwise the next user on a shared device sees the
        // previous user's data.
        Task { await purge?() }
        state = .guest
    }
}
