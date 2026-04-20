import SwiftUI

struct BadgeCollection: View {
    let memberships: [Membership]
    let orgsByID: [UUID: Organization]
    let onSelect: (Membership) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: BuzzSpacing.md),
        GridItem(.flexible(), spacing: BuzzSpacing.md)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            sectionHeader
            if sorted.isEmpty {
                EmptyBadgesCard()
            } else {
                LazyVGrid(columns: columns, spacing: BuzzSpacing.md) {
                    ForEach(sorted) { membership in
                        if let org = orgsByID[membership.organizationID] {
                            Button { onSelect(membership) } label: {
                                BadgeCard(organization: org, membership: membership, compact: true)
                            }
                            .buttonStyle(PressableScale())
                        }
                    }
                }
            }
        }
        .padding(.horizontal, BuzzSpacing.lg)
    }

    private var sectionHeader: some View {
        HStack {
            Text("Badges")
                .font(BuzzFont.title2)
                .foregroundStyle(BuzzColor.textPrimary)
            Text("\(sorted.count)")
                .font(BuzzFont.captionBold)
                .foregroundStyle(BuzzColor.textTertiary)
                .padding(.horizontal, BuzzSpacing.sm)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.white.opacity(0.08)))
            Spacer()
        }
    }

    /// Prestige first, then officer, then member; within tier by most-recently-joined.
    /// Pending invites are excluded — they show in the Invitations section instead.
    private var sorted: [Membership] {
        memberships
            .filter { $0.isActive }
            .sorted { a, b in
                let pa = a.role.tier.priority
                let pb = b.role.tier.priority
                if pa != pb { return pa < pb }
                return a.since > b.since
            }
    }
}

private extension BadgeTier {
    var priority: Int {
        switch self {
        case .prestige: 0
        case .officer: 1
        case .member: 2
        }
    }
}

private struct PressableScale: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.snappy(duration: 0.14), value: configuration.isPressed)
    }
}
