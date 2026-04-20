import SwiftUI

/// Inline section on the profile screen listing all current pending invitations.
struct PendingInvitesSection: View {
    let invites: [Membership]
    let orgsByID: [UUID: Organization]
    let onRespond: (UUID, Bool) -> Void

    var body: some View {
        if invites.isEmpty { EmptyView() } else {
            VStack(alignment: .leading, spacing: BuzzSpacing.md) {
                HStack(spacing: BuzzSpacing.xs) {
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(BuzzColor.accent)
                    Text("Invitations")
                        .font(BuzzFont.title2)
                        .foregroundStyle(BuzzColor.textPrimary)
                    Text("\(invites.count)")
                        .font(BuzzFont.captionBold)
                        .foregroundStyle(BuzzColor.textTertiary)
                        .padding(.horizontal, BuzzSpacing.sm)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                }
                ForEach(invites) { invite in
                    if let org = orgsByID[invite.organizationID] {
                        PendingInviteCard(
                            organization: org,
                            membership: invite,
                            onAccept: { onRespond(invite.id, true) },
                            onDecline: { onRespond(invite.id, false) }
                        )
                    }
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
        }
    }
}
