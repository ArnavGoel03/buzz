import SwiftUI

/// Polished club tile — serif display name, mono meta row, rim-lit card with a
/// subtle color wash from the club's accent. One visual language with the web.
struct ClubCard: View {
    let organization: Organization
    /// True when this org has a live or imminent event — surfaces the pulsing dot
    /// so Discovery is "who's buzzing tonight," not a static directory.
    var isBuzzing: Bool = false
    @State private var pulse: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            HStack(alignment: .top) {
                BadgeLogoMark(organization: organization, size: 44, ringWidth: 2)
                Spacer()
                HStack(spacing: BuzzSpacing.xs) {
                    if isBuzzing {
                        buzzingDot
                            .accessibilityLabel("\(organization.name) has a live or imminent event")
                    }
                    if organization.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(organization.accent)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(organization.name)
                    .font(BuzzFont.displaySM)
                    .foregroundStyle(BuzzColor.textPrimary)
                    .kerning(-0.3)
                    .lineLimit(1)
                Text(organization.tagline)
                    .font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textSecondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(spacing: BuzzSpacing.xs) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 10, weight: .semibold))
                Text("\(organization.memberCount)")
                    .font(BuzzFont.monoSmall)
                if organization.instagramURL != nil {
                    // Subtle cross-platform cue; the org detail page is the right place to act on it.
                    // Keeps the card itself un-cluttered while telling students "they exist there too."
                    Text("·")
                        .font(BuzzFont.monoSmall)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(organization.accent.opacity(0.9))
                        .accessibilityLabel("Instagram linked")
                }
                Spacer()
                Text(organization.category.displayName.uppercased())
                    .font(BuzzFont.monoSmall)
                    .tracking(0.8)
            }
            .foregroundStyle(BuzzColor.textTertiary)
        }
        .padding(BuzzSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [organization.accent.opacity(0.10), BuzzColor.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .rimCard()
        .overlay(
            // Faint accent-colored rim on top of the rim-card for brand tint
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerLarge, style: .continuous)
                .stroke(organization.accent.opacity(0.14), lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            // When buzzing, the accent rim lifts to signal attention — subtle, not shouty.
            if isBuzzing {
                RoundedRectangle(cornerRadius: BuzzSpacing.cornerLarge, style: .continuous)
                    .stroke(BuzzColor.live.opacity(0.45), lineWidth: 1.2)
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            guard isBuzzing else { return }
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var buzzingDot: some View {
        ZStack {
            Circle()
                .fill(BuzzColor.live.opacity(pulse ? 0.0 : 0.35))
                .frame(width: pulse ? 18 : 10, height: pulse ? 18 : 10)
            Circle()
                .fill(BuzzColor.live)
                .frame(width: 7, height: 7)
        }
        .frame(width: 18, height: 18)
    }
}
