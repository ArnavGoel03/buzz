import SwiftUI

struct OrganizationStatsRow: View {
    let organization: Organization

    var body: some View {
        HStack(spacing: BuzzSpacing.lg) {
            stat(icon: "person.3.fill", value: "\(organization.memberCount)", label: "members")
            divider
            stat(icon: organization.category.icon, value: organization.category.displayName, label: "")
            if let year = organization.foundedYear {
                divider
                stat(icon: "calendar", value: "\(year)", label: "founded")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BuzzSpacing.md)
        .padding(.horizontal, BuzzSpacing.lg)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }

    private func stat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(organization.accent)
            Text(value)
                .font(BuzzFont.bodyEmphasis)
                .foregroundStyle(BuzzColor.textPrimary)
            if !label.isEmpty {
                Text(label)
                    .font(BuzzFont.micro)
                    .foregroundStyle(BuzzColor.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(BuzzColor.border)
            .frame(width: 1, height: 28)
    }
}
