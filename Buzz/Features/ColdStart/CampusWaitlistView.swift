import SwiftUI

/// Round 1 — campus not yet supported? Capture the email, promise to notify when we
/// launch at that school. Critical so we don't lose users searching for campuses that
/// aren't seeded yet.
struct CampusWaitlistView: View {
    let requestedCampus: String?
    @State private var email = ""
    @State private var submitted = false

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            Image(systemName: "hourglass")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(BuzzColor.accent)
                .padding(.top, BuzzSpacing.xl)
            Text("Not at \(requestedCampus ?? "your campus") yet")
                .font(BuzzFont.title)
                .multilineTextAlignment(.center)
            Text("We'll launch as soon as we have ~20 students and one ambassador at your school. Want to be first?")
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BuzzSpacing.lg)

            if submitted {
                Label("You're on the list. We'll email when Buzz launches at your campus.", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(BuzzColor.accent)
                    .padding(BuzzSpacing.lg)
                    .multilineTextAlignment(.center)
            } else {
                TextField("your@school.edu", text: $email)
                    .iosLowercaseInput()
                    .padding(BuzzSpacing.md)
                    .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
                    .padding(.horizontal, BuzzSpacing.lg)

                Button {
                    Haptics.success()
                    submitted = true
                } label: {
                    Text("Add me")
                        .font(BuzzFont.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, BuzzSpacing.md)
                        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.accent))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, BuzzSpacing.lg)
                .disabled(email.isEmpty || !email.contains("@"))
            }
            Spacer()
        }
        .background(BuzzColor.background.ignoresSafeArea())
    }
}
