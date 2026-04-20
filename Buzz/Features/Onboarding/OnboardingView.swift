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
        VStack(spacing: 0) {
            CampusPickerStep(selection: $selectedCampus, suggested: suggestedCampus)
                .padding(.horizontal, BuzzSpacing.lg)
                .padding(.top, BuzzSpacing.xxl)
            Spacer()
            continueButton
                .padding(.horizontal, BuzzSpacing.lg)
                .padding(.bottom, BuzzSpacing.xl)
        }
        .background(BuzzColor.background.ignoresSafeArea())
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
