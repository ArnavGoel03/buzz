import SwiftUI

struct MemberRow: View {
    let profile: Profile
    let membership: Membership
    let organization: Organization

    var body: some View {
        HStack(spacing: BuzzSpacing.md) {
            ProfileAvatar(profile: profile, size: 40)
            VStack(alignment: .leading, spacing: 1) {
                Text(profile.displayName)
                    .font(BuzzFont.bodyEmphasis)
                    .foregroundStyle(BuzzColor.textPrimary)
                    .accessibilityLabel(Text(profile.displayName + " " + profile.displayHandle))
                HStack(spacing: 4) {
                    Image(systemName: membership.role.icon)
                        .font(.system(size: 10, weight: .bold))
                    Text(membership.role.displayName)
                        .font(BuzzFont.caption)
                }
                .foregroundStyle(roleTint)
            }
            Spacer()
        }
        .padding(.vertical, BuzzSpacing.sm)
    }

    private var roleTint: Color {
        switch membership.role.tier {
        case .prestige, .officer: organization.accent
        case .member: BuzzColor.textSecondary
        }
    }
}
