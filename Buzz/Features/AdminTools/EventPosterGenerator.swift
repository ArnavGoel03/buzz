import SwiftUI

/// Generates a 9:16 Story-format poster image for an event. Officer hits "Share to
/// Instagram" and gets a JPEG ready to upload — no Canva, no Figma, no Photoshop.
///
/// Uses ImageRenderer (iOS 16+, macOS 13+) so it works on every platform.
@MainActor
enum EventPosterGenerator {
    static func render(_ event: Event, organization: Organization?) -> Image? {
        let view = PosterContent(event: event, organization: organization)
            .frame(width: 1080, height: 1920)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 1.0
        #if canImport(UIKit)
        if let ui = renderer.uiImage { return Image(uiImage: ui) }
        #elseif canImport(AppKit)
        if let ns = renderer.nsImage { return Image(nsImage: ns) }
        #endif
        return nil
    }
}

private struct PosterContent: View {
    let event: Event
    let organization: Organization?

    var body: some View {
        let tint = organization?.accent ?? event.category.tint
        ZStack {
            LinearGradient(colors: [tint.opacity(0.85), .black],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: 28) {
                Spacer()
                if let org = organization {
                    HStack(spacing: 16) {
                        BadgeLogoMark(organization: org, size: 80, ringWidth: 3)
                        VStack(alignment: .leading) {
                            Text(org.name).font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("PRESENTS")
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                                .tracking(4)
                        }
                    }
                }
                Text(event.title)
                    .font(.system(size: 92, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(4)
                    .minimumScaleFactor(0.5)
                if !event.summary.isEmpty {
                    Text(event.summary)
                        .font(.system(size: 36, weight: .regular, design: .default))
                        .foregroundStyle(.white.opacity(0.9))
                }
                VStack(alignment: .leading, spacing: 12) {
                    posterRow("calendar", text: dateLine)
                    posterRow("mappin", text: event.location.name)
                    posterRow("sparkles", text: "Get Buzz · scan to RSVP")
                }
                Spacer()
            }
            .padding(.horizontal, 80)
            .padding(.vertical, 120)
        }
        .ignoresSafeArea()
    }

    private func posterRow(_ icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white.opacity(0.85))
            Text(text)
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var dateLine: String {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d · h:mm a"
        f.timeZone = event.timezone.flatMap(TimeZone.init(identifier:)) ?? .current
        return f.string(from: event.startsAt)
    }
}
