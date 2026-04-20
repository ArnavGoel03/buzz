import SwiftUI

/// Snapchat-style streak counter. Lives on the profile and as a small flame icon in the
/// nav bar when the user has an active streak. Drives habit formation — students don't
/// want to lose their streak.
struct StreakBadge: View {
    let weeks: Int

    var body: some View {
        HStack(spacing: BuzzSpacing.xs) {
            Image(systemName: "flame.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(LinearGradient(colors: [.orange, .red],
                                                 startPoint: .top, endPoint: .bottom))
            Text("\(weeks)")
                .font(BuzzFont.captionBold)
                .foregroundStyle(BuzzColor.textPrimary)
            Text(weeks == 1 ? "week" : "weeks")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
        }
        .padding(.horizontal, BuzzSpacing.sm)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(LinearGradient(colors: [.orange.opacity(0.2), .red.opacity(0.15)],
                                     startPoint: .leading, endPoint: .trailing))
        )
        .overlay(Capsule().stroke(.orange.opacity(0.4), lineWidth: 1))
    }
}
