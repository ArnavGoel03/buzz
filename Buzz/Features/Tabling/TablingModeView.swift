import SwiftUI

/// Full-screen booth display for officers running a tabling event (orientation fair, club fair).
/// Shows a giant QR + AirDrop button. Visitors with no Buzz installed land in an App Clip
/// preview; visitors with Buzz installed jump straight to the org page.
struct TablingModeView: View {
    let organization: Organization
    @Environment(\.dismiss) private var dismiss
    @State private var visitorCount = 0

    var body: some View {
        ZStack {
            background
            VStack(spacing: BuzzSpacing.xl) {
                topBar
                Spacer()
                BadgeLogoMark(organization: organization, size: 110, ringWidth: 4)
                Text(organization.name)
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text(organization.tagline)
                    .font(BuzzFont.headline)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                qrPanel
                Spacer()
                airdropRow
                visitorPill
            }
            .padding(BuzzSpacing.xxl)
        }
        .iosOnlyHideStatusBar()
        .iosOnlyHidePersistentOverlays()
    }

    private var background: some View {
        LinearGradient(
            colors: [organization.accent.opacity(0.55), .black],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
    }

    private var qrPanel: some View {
        VStack(spacing: BuzzSpacing.md) {
            qrImage
                .frame(width: 280, height: 280)
                .padding(BuzzSpacing.lg)
                .background(RoundedRectangle(cornerRadius: 28).fill(.white))
            Text("Scan with your phone camera")
                .font(BuzzFont.headline)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    private var qrImage: some View {
        Group {
            if let img = QRCode.image(for: BuzzLink.organization(handle: organization.handle).absoluteString) {
                img.resizable().interpolation(.none).scaledToFit()
            } else {
                Image(systemName: "qrcode").resizable().scaledToFit()
            }
        }
    }

    private var airdropRow: some View {
        ShareLink(
            item: BuzzLink.organization(handle: organization.handle),
            subject: Text(organization.name),
            preview: SharePreview(organization.name, image: Image(systemName: "qrcode"))
        ) {
            HStack(spacing: BuzzSpacing.sm) {
                Image(systemName: "airplayaudio")
                    .font(.system(size: 18, weight: .bold))
                Text("AirDrop to nearby iPhone")
                    .font(BuzzFont.headline)
            }
            .foregroundStyle(.black)
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.vertical, BuzzSpacing.md)
            .background(Capsule().fill(.white))
        }
        .simultaneousGesture(TapGesture().onEnded {
            Haptics.tap()
            visitorCount += 1
        })
    }

    private var visitorPill: some View {
        HStack(spacing: BuzzSpacing.xs) {
            Image(systemName: "person.fill.badge.plus")
                .font(.system(size: 12, weight: .bold))
            Text("\(visitorCount) shared today")
                .font(BuzzFont.captionBold)
        }
        .foregroundStyle(.white.opacity(0.6))
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, BuzzSpacing.sm)
        .background(Capsule().fill(.white.opacity(0.08)))
    }
}
