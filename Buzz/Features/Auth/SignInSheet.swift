import SwiftUI
import AuthenticationServices

/// Frictionless sign-in. Exactly one screen. Each provider is one tap — no password, no
/// email to type first, no multi-step wizard. Appears only when a personalized action
/// needs identity (RSVP, profile, org admin). Guests never see this on launch.
struct SignInSheet: View {
    @Environment(AuthSession.self) private var auth
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            header
            Spacer()
            buttons
            Spacer()
            footerNote
        }
        .padding(BuzzSpacing.xl)
        .background(BuzzColor.background.ignoresSafeArea())
        .presentationCornerRadius(32)
    }

    private var header: some View {
        VStack(spacing: BuzzSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(BuzzColor.accent)
                .padding(.top, BuzzSpacing.xl)
            Text("Join Buzz")
                .font(BuzzFont.largeTitle)
                .foregroundStyle(BuzzColor.textPrimary)
            Text("Takes 3 taps. No passwords, no forms.")
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var buttons: some View {
        VStack(spacing: BuzzSpacing.md) {
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                // VULN #80 patch: previously the closure ignored Result, treating cancel /
                // error as success. Now we proceed only on .success. (Production must hand
                // the credential's identityToken to Supabase for server-side verification.)
                switch result {
                case .success(let authResponse):
                    guard authResponse.credential is ASAuthorizationAppleIDCredential else { return }
                    Task {
                        Haptics.success()
                        await auth.continueWithApple()
                        dismiss()
                    }
                case .failure:
                    Haptics.warning()
                }
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 54)
            .clipShape(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium))

            // VULN #86 patch: Google + Email buttons granted auth WITHOUT any verification
            // in the stub — anyone tapping was logged in as the mock user. They're now
            // disabled in release builds and loudly marked as stubs in DEBUG.
            #if DEBUG
            Button {
                Haptics.tap()
                Task {
                    await auth.continueWithGoogle()
                    dismiss()
                }
            } label: {
                HStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Continue with Google")
                            .font(BuzzFont.headline)
                        Text("DEBUG STUB — no verification")
                            .font(BuzzFont.micro)
                            .foregroundStyle(BuzzColor.live)
                    }
                }
                .foregroundStyle(BuzzColor.textPrimary)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
                .overlay(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).stroke(BuzzColor.border, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Button {
                Haptics.tap()
                Task {
                    await auth.continueWithEmail(email)
                    dismiss()
                }
            } label: {
                Text("Use school email (DEBUG STUB — no OTP)")
                    .font(BuzzFont.captionBold)
                    .foregroundStyle(BuzzColor.live)
            }
            .buttonStyle(.plain)
            .padding(.top, BuzzSpacing.xs)
            #else
            // Production: wire `GIDSignIn.sharedInstance.signIn(...)` for Google and a real
            // email-OTP UI before re-enabling these.
            Text("More sign-in options coming soon")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textTertiary)
            #endif
        }
    }

    private var footerNote: some View {
        Text("Any sign-in works — switch phones later and pick any method to return to the same account.")
            .font(BuzzFont.caption)
            .foregroundStyle(BuzzColor.textTertiary)
            .multilineTextAlignment(.center)
    }
}
