import SwiftUI

struct RushChapterCard: View {
    let organization: Organization
    let isInterested: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
                BadgeLogoMark(organization: organization, size: 48, ringWidth: 2)
                Text(organization.name)
                    .font(BuzzFont.bodyEmphasis)
                    .foregroundStyle(BuzzColor.textPrimary)
                    .lineLimit(2)
                Text(organization.tagline)
                    .font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textSecondary)
                    .lineLimit(2)
                Spacer(minLength: 0)
                HStack {
                    Spacer()
                    Image(systemName: isInterested ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(isInterested ? Color.pink : BuzzColor.textTertiary)
                        .scaleEffect(isInterested ? 1.2 : 1.0)
                        .animation(.spring(duration: 0.25, bounce: 0.5), value: isInterested)
                }
            }
            .padding(BuzzSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                    .fill(LinearGradient(
                        colors: [organization.accent.opacity(isInterested ? 0.3 : 0.10), BuzzColor.surface],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
            )
            .overlay(
                RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                    .stroke(organization.accent.opacity(isInterested ? 0.6 : 0.2), lineWidth: isInterested ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
