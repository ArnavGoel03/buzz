import SwiftUI

struct EventShareButton: View {
    let event: Event

    var body: some View {
        ShareLink(
            item: BuzzLink.event(event.id),
            subject: Text(event.title),
            message: Text(messageBody),
            preview: SharePreview(event.title, image: Image(systemName: "calendar"))
        ) {
            // VULN #79 patch: 44pt min tap target per Apple HIG.
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(BuzzColor.textPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.ultraThinMaterial))
                .contentShape(Circle())
        }
        .simultaneousGesture(TapGesture().onEnded { Haptics.tap() })
    }

    private var messageBody: String {
        let df = DateFormatter()
        df.dateFormat = "EEE h:mm a"
        return "\(event.title) — \(df.string(from: event.startsAt)) @ \(event.location.name). On Buzz."
    }
}
