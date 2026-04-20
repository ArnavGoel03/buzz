import SwiftUI

/// Circular org logo with a tint ring and a fallback to the org's initial.
/// Used by BadgeCard and the organization hero.
struct BadgeLogoMark: View {
    let organization: Organization
    var size: CGFloat = 56
    var ringWidth: CGFloat = 2

    var body: some View {
        ZStack {
            Circle()
                .fill(organization.accent.opacity(0.22))
            if let url = organization.logoURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    initial
                }
            } else {
                initial
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(
                LinearGradient(colors: [organization.accent, organization.accent.opacity(0.4)],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                lineWidth: ringWidth
            )
        )
    }

    private var initial: some View {
        Text(String(organization.name.first ?? "•"))
            .font(.system(size: size * 0.42, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
    }
}
