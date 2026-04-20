import SwiftUI

/// Round 1 — viral invite codes. Every user can share a code; each redemption credits
/// the inviter (for leaderboard later). Codes are short, memorable, lowercase alphanumeric.
struct InviteCodeSheet: View {
    let myCode: String
    let campus: String
    let usesRemaining: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            Image(systemName: "gift.fill")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(BuzzColor.accent)
                .padding(.top, BuzzSpacing.xl)
            Text("Invite your campus").font(BuzzFont.title)
            Text("Share your code. Everyone who joins with it shows up in your 'brought to Buzz' leaderboard.")
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BuzzSpacing.lg)

            VStack(spacing: BuzzSpacing.sm) {
                Text(myCode)
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundStyle(BuzzColor.accent)
                    .padding(BuzzSpacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
                Text("\(usesRemaining) uses left · \(CampusRegistry.displayName(for: campus))")
                    .font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textTertiary)
            }
            .padding(.horizontal, BuzzSpacing.lg)

            ShareLink(item: "Join me on Buzz → https://buzz.app/join/\(myCode)") {
                Label("Share with friends", systemImage: "square.and.arrow.up")
                    .font(BuzzFont.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BuzzSpacing.md)
                    .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.accent))
            }
            .padding(.horizontal, BuzzSpacing.lg)

            Spacer()
        }
        .background(BuzzColor.background.ignoresSafeArea())
    }
}
