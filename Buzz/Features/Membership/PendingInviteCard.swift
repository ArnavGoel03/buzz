import SwiftUI

/// Shown on the user's profile when they have pending org invitations. Two-tap accept/decline.
struct PendingInviteCard: View {
    let organization: Organization
    let membership: Membership
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            HStack(spacing: BuzzSpacing.md) {
                BadgeLogoMark(organization: organization, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(organization.name) invited you")
                        .font(BuzzFont.bodyEmphasis)
                        .foregroundStyle(BuzzColor.textPrimary)
                        .lineLimit(2)
                    HStack(spacing: 4) {
                        Image(systemName: membership.role.icon)
                            .font(.system(size: 10, weight: .bold))
                        Text("as \(membership.role.displayName)")
                            .font(BuzzFont.caption)
                    }
                    .foregroundStyle(organization.accent)
                }
                Spacer()
            }
            HStack(spacing: BuzzSpacing.sm) {
                Button {
                    Haptics.warning()
                    onDecline()
                } label: {
                    Text("Decline")
                        .font(BuzzFont.captionBold)
                        .foregroundStyle(BuzzColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, BuzzSpacing.sm)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                }
                .buttonStyle(.plain)
                Button {
                    Haptics.success()
                    onAccept()
                } label: {
                    Text("Accept")
                        .font(BuzzFont.captionBold)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, BuzzSpacing.sm)
                        .background(Capsule().fill(organization.accent))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(BuzzSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                .fill(LinearGradient(colors: [organization.accent.opacity(0.15), BuzzColor.surface],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                .stroke(organization.accent.opacity(0.35), lineWidth: 1)
        )
    }
}
