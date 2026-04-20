import SwiftUI

/// Slim banner that appears at the top when connectivity is lost. Tells the user we're
/// showing saved data instead of failing silently.
struct OfflineBanner: View {
    var body: some View {
        HStack(spacing: BuzzSpacing.sm) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 12, weight: .bold))
            Text("Offline — showing saved events")
                .font(BuzzFont.captionBold)
        }
        .foregroundStyle(.black)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(BuzzColor.accent)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
