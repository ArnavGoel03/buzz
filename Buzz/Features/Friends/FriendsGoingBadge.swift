import SwiftUI

/// "5 friends going" pill — the single most powerful social-proof unit in the app.
/// Renders avatars of up to 3 friends + a count. Drives the FOMO that turns "maybe"
/// into "going."
struct FriendsGoingBadge: View {
    let friends: [Profile]    // friends RSVP'd to this event
    let totalCount: Int       // total RSVPs (for fallback when we have 0 friend overlap)

    var body: some View {
        if friends.isEmpty {
            HStack(spacing: BuzzSpacing.xs) {
                Image(systemName: "person.fill")
                    .font(.system(size: 11, weight: .bold))
                Text("\(totalCount) going")
                    .font(BuzzFont.captionBold)
            }
            .foregroundStyle(BuzzColor.textSecondary)
        } else {
            HStack(spacing: BuzzSpacing.xs) {
                avatarStack
                Text(label)
                    .font(BuzzFont.captionBold)
                    .foregroundStyle(BuzzColor.textPrimary)
            }
            .padding(.horizontal, BuzzSpacing.sm)
            .padding(.vertical, 4)
            .background(Capsule().fill(BuzzColor.accent.opacity(0.18)))
            .overlay(Capsule().stroke(BuzzColor.accent.opacity(0.4), lineWidth: 1))
        }
    }

    private var avatarStack: some View {
        HStack(spacing: -8) {
            ForEach(friends.prefix(3)) { friend in
                ProfileAvatar(profile: friend, size: 22)
                    .overlay(Circle().stroke(BuzzColor.background, lineWidth: 2))
            }
        }
    }

    private var label: String {
        let count = friends.count
        let names = friends.prefix(1).map(\.displayName)
        if count == 1 { return "\(names[0]) is going" }
        if count == 2 { return "\(names[0]) +1 going" }
        return "\(names[0]) +\(count - 1) going"
    }
}
