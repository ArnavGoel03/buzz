import SwiftUI

/// At-the-door check-in. The officer's iPhone displays a per-event QR; arriving members
/// scan it from their own phone via the camera, confirming attendance.
///
/// This view shows the officer-side "I'm checking people in" panel with the event QR +
/// a running count. The receiver-side camera scan + record-attendance write is in the
/// member's own app and goes through `event_check_ins` insert (RLS lets only org officers
/// write — so we'll need a DB-side validator that lets the *attendee* self-check-in via
/// a signed token in the QR. Marked TODO; ships in v0.5.)
struct CheckInScannerView: View {
    let event: Event
    @State private var checkedInCount: Int = 0

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            header
            qrPanel
            stats
            Spacer()
            footer
        }
        .padding(BuzzSpacing.xl)
        .background(BuzzColor.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(spacing: BuzzSpacing.xs) {
            Text("Checking in")
                .font(BuzzFont.captionBold)
                .foregroundStyle(BuzzColor.textTertiary)
            Text(event.title)
                .font(BuzzFont.title2)
                .foregroundStyle(BuzzColor.textPrimary)
                .multilineTextAlignment(.center)
        }
    }

    private var qrPanel: some View {
        VStack(spacing: BuzzSpacing.sm) {
            qrImage
                .frame(width: 280, height: 280)
                .padding(BuzzSpacing.lg)
                .background(RoundedRectangle(cornerRadius: 28).fill(.white))
            Text("Scan with your Buzz app to check in")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
        }
    }

    private var qrImage: some View {
        // The QR encodes a signed check-in URL like
        // `buzz://checkin/<event_id>?token=<HMAC>`. Server validates the HMAC before
        // inserting into event_check_ins. Real signing wired with backend.
        let url = "buzz://checkin/\(event.id.uuidString)?token=DEV_STUB"
        return Group {
            if let img = QRCode.image(for: url) {
                img.resizable().interpolation(.none).scaledToFit()
            } else {
                Image(systemName: "qrcode").resizable().scaledToFit()
            }
        }
    }

    private var stats: some View {
        HStack(spacing: BuzzSpacing.lg) {
            StatBlock(label: "Checked in", value: "\(checkedInCount)", tint: BuzzColor.accent)
            StatBlock(label: "RSVP'd", value: "\(event.rsvpCount)", tint: BuzzColor.textPrimary)
            if let cap = event.capacity {
                StatBlock(label: "Capacity", value: "\(cap)", tint: BuzzColor.textSecondary)
            }
        }
    }

    private var footer: some View {
        Text("Officers can also tap to manually check someone in from the Members tab.")
            .font(BuzzFont.caption)
            .foregroundStyle(BuzzColor.textTertiary)
            .multilineTextAlignment(.center)
    }
}

private struct StatBlock: View {
    let label: String, value: String, tint: Color
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(BuzzFont.title).foregroundStyle(tint)
            Text(label).font(BuzzFont.micro).foregroundStyle(BuzzColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BuzzSpacing.md)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }
}
