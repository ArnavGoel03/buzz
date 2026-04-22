import SwiftUI

/// Pill row for an org's off-platform presence — Instagram + website.
/// Only renders pills we actually have a safe URL for. Hidden entirely when both are absent.
/// Tappable links open in the default handler (Instagram app if installed, else Safari).
struct OrgExternalLinksRow: View {
    let organization: Organization

    var body: some View {
        let ig = organization.instagramURL
        let web = organization.safeWebsiteURL
        if ig == nil && web == nil {
            EmptyView()
        } else {
            HStack(spacing: BuzzSpacing.sm) {
                if let ig, let handle = organization.instagramHandle {
                    Link(destination: ig) {
                        pill(
                            glyph: "camera.fill",
                            primary: "@\(handle.hasPrefix("@") ? String(handle.dropFirst()) : handle)",
                            secondary: "Instagram"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open Instagram profile for \(organization.name)")
                    .simultaneousGesture(TapGesture().onEnded { Haptics.tap() })
                }
                if let web {
                    Link(destination: web) {
                        pill(
                            glyph: "safari.fill",
                            primary: shortHost(web),
                            secondary: "Website"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open website for \(organization.name)")
                    .simultaneousGesture(TapGesture().onEnded { Haptics.tap() })
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func pill(glyph: String, primary: String, secondary: String) -> some View {
        HStack(spacing: BuzzSpacing.xs) {
            Image(systemName: glyph)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(organization.accent)
            VStack(alignment: .leading, spacing: 0) {
                Text(primary)
                    .font(BuzzFont.captionBold)
                    .foregroundStyle(BuzzColor.textPrimary)
                    .lineLimit(1)
                Text(secondary.uppercased())
                    .font(BuzzFont.monoSmall)
                    .tracking(0.8)
                    .foregroundStyle(BuzzColor.textTertiary)
            }
        }
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, BuzzSpacing.xs + 2)
        .background(
            Capsule(style: .continuous)
                .fill(BuzzColor.surface)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(organization.accent.opacity(0.22), lineWidth: 1)
        )
    }

    private func shortHost(_ url: URL) -> String {
        let host = (url.host ?? url.absoluteString).lowercased()
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}
