import SwiftUI

/// Tier-aware badge card. Member → clean, Officer → emphasized, Prestige → holographic shimmer.
struct BadgeCard: View {
    let organization: Organization
    let membership: Membership
    var compact: Bool = false
    /// VULN #41 patch: hidden badges only fade-render when the viewer is the owner. For other
    /// viewers, hidden badges are filtered out by the parent collection — never reach this view.
    var viewerIsOwner: Bool = true

    private var tier: BadgeTier { membership.role.tier }

    var body: some View {
        HStack(spacing: BuzzSpacing.md) {
            BadgeLogoMark(organization: organization, size: compact ? 44 : 54)
            VStack(alignment: .leading, spacing: 3) {
                Text(organization.name)
                    .font(BuzzFont.bodyEmphasis)
                    .foregroundStyle(BuzzColor.textPrimary)
                    .lineLimit(1)
                roleRow
                sinceLabel
            }
            Spacer(minLength: 0)
        }
        .padding(BuzzSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .overlay(cardBorder)
        .overlay(shimmerOverlay)
        .clipShape(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium))
        .shadow(color: shadowColor, radius: shadowRadius, y: 4)
        .opacity(viewerIsOwner ? (membership.isVisible ? 1.0 : 0.45) : 1.0)
        .overlay(alignment: .topTrailing) { if viewerIsOwner { hiddenIndicator } }
    }

    // ── Role line ────────────────────────────────────────────────────────────
    private var roleRow: some View {
        HStack(spacing: 4) {
            Image(systemName: membership.role.icon)
                .font(.system(size: 11, weight: .bold))
            Text(membership.role.displayName.uppercased())
                .font(BuzzFont.micro)
        }
        .foregroundStyle(tier == .member ? BuzzColor.textSecondary : organization.accent)
    }

    private var sinceLabel: some View {
        Text("Since " + sinceYear)
            .font(BuzzFont.caption)
            .foregroundStyle(BuzzColor.textTertiary)
    }

    private var sinceYear: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        return df.string(from: membership.since)
    }

    // ── Tier visuals ─────────────────────────────────────────────────────────
    @ViewBuilder
    private var cardBackground: some View {
        switch tier {
        case .member:
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                .fill(BuzzColor.surface)
        case .officer:
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                .fill(LinearGradient(colors: [organization.accent.opacity(0.18), BuzzColor.surface],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        case .prestige:
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                .fill(LinearGradient(colors: [organization.accent.opacity(0.45),
                                              organization.accent.opacity(0.15),
                                              BuzzColor.surface],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
            .stroke(organization.accent.opacity(borderOpacity), lineWidth: borderWidth)
    }

    private var borderOpacity: Double {
        switch tier {
        case .member: 0.18
        case .officer: 0.35
        case .prestige: 0.55
        }
    }

    private var borderWidth: CGFloat { tier == .prestige ? 1.5 : 1.0 }

    @ViewBuilder
    private var shimmerOverlay: some View {
        if tier == .prestige {
            BadgeShimmer(tint: organization.accent)
                .clipShape(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium))
        }
    }

    private var shadowColor: Color {
        switch tier {
        case .member: Color.black.opacity(0.35)
        case .officer: organization.accent.opacity(0.25)
        case .prestige: organization.accent.opacity(0.45)
        }
    }

    private var shadowRadius: CGFloat {
        switch tier {
        case .member: 4
        case .officer: 8
        case .prestige: 14
        }
    }

    @ViewBuilder
    private var hiddenIndicator: some View {
        if !membership.isVisible {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .padding(6)
                .background(Circle().fill(.black.opacity(0.55)))
                .padding(8)
        }
    }
}
