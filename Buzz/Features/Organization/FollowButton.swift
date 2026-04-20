import SwiftUI

struct FollowButton: View {
    let organization: Organization
    @Binding var isFollowing: Bool

    var body: some View {
        Button {
            Haptics.success()
            isFollowing.toggle()
        } label: {
            HStack(spacing: BuzzSpacing.sm) {
                Image(systemName: isFollowing ? "checkmark" : "plus")
                    .font(.system(size: 14, weight: .bold))
                Text(isFollowing ? "Following" : "Follow")
                    .font(BuzzFont.headline)
            }
            .foregroundStyle(isFollowing ? BuzzColor.textPrimary : .black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BuzzSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                    .fill(isFollowing ? BuzzColor.surface : organization.accent)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                    .stroke(isFollowing ? BuzzColor.border : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.2), value: isFollowing)
    }
}
