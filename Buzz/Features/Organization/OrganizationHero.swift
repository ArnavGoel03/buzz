import SwiftUI

struct OrganizationHero: View {
    let organization: Organization

    var body: some View {
        ZStack(alignment: .bottom) {
            cover
            VStack(spacing: BuzzSpacing.sm) {
                BadgeLogoMark(organization: organization, size: 84, ringWidth: 3)
                    .shadow(color: organization.accent.opacity(0.5), radius: 12)
                HStack(spacing: BuzzSpacing.xs) {
                    Text(organization.name)
                        .font(BuzzFont.title)
                        .foregroundStyle(BuzzColor.textPrimary)
                    if organization.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(organization.accent)
                    }
                }
                Text(organization.tagline)
                    .font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BuzzSpacing.lg)
            }
            .offset(y: 60)
        }
        .padding(.bottom, 80)
    }

    private var cover: some View {
        Group {
            if let url = organization.coverURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: { gradient }
            } else {
                gradient
            }
        }
        .frame(height: 160)
        .clipped()
        .overlay(
            LinearGradient(colors: [.clear, BuzzColor.background],
                           startPoint: .top, endPoint: .bottom)
        )
    }

    private var gradient: some View {
        LinearGradient(
            colors: [organization.accent, organization.accent.opacity(0.3), BuzzColor.background],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
}
