import SwiftUI

/// Org poster: one printable QR replaces stacks of paper flyers. Officer prints once,
/// re-uses every week. Embed at the venue, sticker it on whiteboards, etc.
struct OrgShareSheet: View {
    let organization: Organization

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            poster
                .padding(BuzzSpacing.lg)
            ShareLink(
                item: BuzzLink.organization(handle: organization.handle),
                subject: Text(organization.name),
                preview: SharePreview(organization.name, image: Image(systemName: "qrcode"))
            ) {
                Label("Share link", systemImage: "square.and.arrow.up")
                    .font(BuzzFont.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(BuzzSpacing.md)
                    .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(organization.accent))
            }
            .padding(.horizontal, BuzzSpacing.lg)
            Spacer(minLength: 0)
        }
        .presentationCornerRadius(32)
    }

    private var poster: some View {
        VStack(spacing: BuzzSpacing.md) {
            BadgeLogoMark(organization: organization, size: 60, ringWidth: 2)
            Text(organization.name)
                .font(BuzzFont.title2)
                .foregroundStyle(BuzzColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(organization.tagline)
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
            qrImage
                .frame(width: 220, height: 220)
                .padding(BuzzSpacing.md)
                .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(.white))
            Text("Scan to follow on Buzz")
                .font(BuzzFont.captionBold)
                .foregroundStyle(BuzzColor.textTertiary)
        }
        .padding(BuzzSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(LinearGradient(colors: [organization.accent.opacity(0.25), BuzzColor.surface],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        )
    }

    private var qrImage: some View {
        Group {
            if let img = QRCode.image(for: BuzzLink.organization(handle: organization.handle).absoluteString) {
                img.resizable().interpolation(.none).scaledToFit()
            } else {
                Image(systemName: "qrcode").resizable().scaledToFit().padding(40)
            }
        }
    }
}
