import SwiftUI

/// Shown when a user taps a badge on their profile. Big presentation of the badge,
/// role description, visibility toggle, and a link to the org page.
///
/// VULN #83 patch: previously used local `@State isVisible` which diverged from the parent
/// ProfileViewModel until the user reloaded. Now isVisible is read directly from the
/// passed-in `membership`, so the parent VM is the single source of truth.
struct BadgeDetailSheet: View {
    let organization: Organization
    let membership: Membership
    let onVisibilityChange: (Bool) -> Void
    let onOpenOrganization: () -> Void

    private var isVisible: Bool { membership.isVisible }

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            hero
            meta
            visibilityToggle
            openOrgButton
            Spacer(minLength: 0)
        }
        .padding(BuzzSpacing.lg)
        .presentationCornerRadius(32)
        .privacyScreen()
    }

    private var hero: some View {
        BadgeCard(organization: organization, membership: membership)
            .scaleEffect(1.08)
            .padding(.top, BuzzSpacing.md)
    }

    private var meta: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            Text(organization.tagline)
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var visibilityToggle: some View {
        HStack {
            Image(systemName: isVisible ? "eye.fill" : "eye.slash.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isVisible ? organization.accent : BuzzColor.textSecondary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Show on my profile")
                    .font(BuzzFont.bodyEmphasis)
                Text(isVisible ? "Others can see this badge." : "Only you can see this badge.")
                    .font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textSecondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { isVisible },
                set: { newValue in
                    Haptics.selection()
                    onVisibilityChange(newValue)
                }
            ))
            .labelsHidden()
            .tint(organization.accent)
        }
        .padding(BuzzSpacing.md)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }

    private var openOrgButton: some View {
        Button {
            Haptics.tap()
            onOpenOrganization()
        } label: {
            HStack {
                Text("View \(organization.name)")
                    .font(BuzzFont.headline)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.black)
            .padding(BuzzSpacing.md)
            .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(organization.accent))
        }
        .buttonStyle(.plain)
    }
}
