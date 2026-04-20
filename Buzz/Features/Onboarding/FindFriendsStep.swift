import SwiftUI

/// Final onboarding step before the user lands on the Live tab. Offers three low-friction
/// paths to seed the friend graph — because first-session network density determines
/// whether a student sticks. We know this; it's why BeReal and Snapchat beg for contacts
/// on first launch.
struct FindFriendsStep: View {
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(BuzzColor.accent)
                .padding(.top, BuzzSpacing.xl)
            Text("Bring your friends")
                .font(BuzzFont.title)
                .foregroundStyle(BuzzColor.textPrimary)
            Text("Events are 10× better with the group. Pick any one — you can add more later.")
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BuzzSpacing.lg)

            VStack(spacing: BuzzSpacing.sm) {
                optionCard(
                    icon: "person.crop.rectangle.stack.fill",
                    title: "Match your contacts",
                    body: "We match phone numbers against Buzz users. We never upload names or store numbers."
                ) { onDone() }
                optionCard(
                    icon: "qrcode",
                    title: "Scan a friend's QR",
                    body: "Your friend shows their profile QR, you scan — instant two-way friend."
                ) { onDone() }
                optionCard(
                    icon: "envelope.fill",
                    title: "Paste emails or @handles",
                    body: "Bulk-add a roster — great if you already have a group chat going."
                ) { onDone() }
            }
            .padding(.horizontal, BuzzSpacing.lg)

            Spacer()
            Button("Skip for now") { onDone() }
                .font(BuzzFont.captionBold)
                .foregroundStyle(BuzzColor.textSecondary)
                .padding(.bottom, BuzzSpacing.xl)
        }
        .background(BuzzColor.background.ignoresSafeArea())
    }

    private func optionCard(icon: String, title: String, body: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: BuzzSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(BuzzColor.accent)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(BuzzColor.accent.opacity(0.2)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(BuzzFont.bodyEmphasis).foregroundStyle(BuzzColor.textPrimary)
                    Text(body).font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(BuzzColor.textTertiary)
            }
            .padding(BuzzSpacing.md)
            .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
        }
        .buttonStyle(.plain)
    }
}
