import SwiftUI

struct ClubCard: View {
    let organization: Organization

    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            HStack(alignment: .top) {
                BadgeLogoMark(organization: organization, size: 44, ringWidth: 2)
                Spacer()
                if organization.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(organization.accent)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(organization.name)
                    .font(BuzzFont.bodyEmphasis)
                    .foregroundStyle(BuzzColor.textPrimary)
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
                    .font(BuzzFont.micro)
                Spacer()
                Image(systemName: organization.category.icon)
                    .font(.system(size: 10, weight: .semibold))
                Text(organization.category.displayName)
                    .font(BuzzFont.micro)
            }
            .foregroundStyle(BuzzColor.textTertiary)
        }
        .padding(BuzzSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                .fill(LinearGradient(colors: [organization.accent.opacity(0.08), BuzzColor.surface],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                .stroke(organization.accent.opacity(0.18), lineWidth: 1)
        )
    }
}
