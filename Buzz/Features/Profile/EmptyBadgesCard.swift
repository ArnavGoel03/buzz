import SwiftUI

struct EmptyBadgesCard: View {
    var body: some View {
        VStack(spacing: BuzzSpacing.sm) {
            Image(systemName: "rosette")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(BuzzColor.textTertiary)
            Text("No badges yet")
                .font(BuzzFont.headline)
                .foregroundStyle(BuzzColor.textPrimary)
            Text("Find your clubs in the Clubs tab and you'll see your memberships here.")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BuzzSpacing.lg)
        }
        .frame(maxWidth: .infinity)
        .padding(BuzzSpacing.xl)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }
}
