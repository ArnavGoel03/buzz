import SwiftUI

/// Two-step onboarding after sign-in. Step 1: confirm/pick campus. Step 2: done.
/// Everything else (year, major, bio, avatar) is optional and added later.
struct OnboardingView: View {
    @Environment(AppServices.self) private var services
    @Environment(AuthSession.self) private var auth
    @State private var selectedCampus: Campus?
    @State private var suggestedCampus: Campus?
    @State private var isSubmitting = false

    var body: some View {
        ZStack {
            MetalGradientBackground(intensity: 0.9)
                .overlay(BuzzColor.background.opacity(0.45))
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
                    Text("STEP 1 · YOUR CAMPUS")
                        .font(BuzzFont.monoSmall)
                        .tracking(2.2)
                        .foregroundStyle(BuzzColor.textTertiary)
                    RevealingText(
                        text: "Which school?",
                        font: BuzzFont.display,
                        foreground: BuzzColor.textPrimary
                    )
                    Text("We'll filter every event and club to this campus. You can transfer later.")
                        .font(BuzzFont.body)
                        .foregroundStyle(BuzzColor.textSecondary)
                }
                .padding(.horizontal, BuzzSpacing.lg)
                .padding(.top, BuzzSpacing.xxl)
                .frame(maxWidth: .infinity, alignment: .leading)

                CampusPickerStep(selection: $selectedCampus, suggested: suggestedCampus)
                    .padding(.horizontal, BuzzSpacing.lg)
                    .padding(.top, BuzzSpacing.lg)

                Spacer()
                continueButton
                    .padding(.horizontal, BuzzSpacing.lg)
                    .padding(.bottom, BuzzSpacing.xl)
            }
        }
        .task { suggestNearbyCampus() }
    }

    private var continueButton: some View {
        Button {
            // VULN #74 patch: in-flight guard. Without it a double-tap fires onboarding
            // twice — creates two profile rows (in production via verify_affiliation RPC).
            guard selectedCampus != nil, !isSubmitting else { return }
            Haptics.success()
            isSubmitting = true
            Task {
                let id = (try? await services.profiles.currentProfile().id) ?? UUID()
                auth.completeOnboarding(profileID: id)
                isSubmitting = false
            }
        } label: {
            HStack {
                if isSubmitting { ProgressView().tint(.black) }
                Text(selectedCampus == nil ? "Pick a campus to continue" : "Continue")
                    .font(BuzzFont.headline)
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BuzzSpacing.md)
            .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                .fill(selectedCampus == nil ? Color.white.opacity(0.12) : BuzzColor.accent))
        }
        .buttonStyle(.plain)
        .disabled(selectedCampus == nil || isSubmitting)
        .magneticPress()
    }

    private func suggestNearbyCampus() {
        let coord = services.location.coordinate
        let candidates = CampusRegistry.all().compactMap { c -> (Campus, Double)? in
            guard let cCoord = c.coordinate else { return nil }
            let dx = cCoord.latitude - coord.latitude
            let dy = cCoord.longitude - coord.longitude
            return (c, dx * dx + dy * dy)
        }
        suggestedCampus = candidates.min(by: { $0.1 < $1.1 })?.0
    }
}
