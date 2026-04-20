import SwiftUI

/// "Free pizza in 10 min at Geisel" — the killer organic-growth feature. Surfaces only
/// food-category events flagged as free, served as a notification banner pinned to the
/// top of the Map tab + dedicated tab. Single tap to RSVP and walk over.
struct FreeFoodBeacon: View {
    let event: Event

    var body: some View {
        HStack(spacing: BuzzSpacing.md) {
            Text("🍕")
                .font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: BuzzSpacing.xs) {
                    Text("FREE FOOD")
                        .font(BuzzFont.micro)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(Color.white))
                    if event.isLive { LiveBadge() }
                }
                Text(event.title)
                    .font(BuzzFont.headline)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                Text(event.location.name)
                    .font(BuzzFont.caption)
                    .foregroundStyle(.black.opacity(0.7))
            }
            Spacer()
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
        }
        .padding(BuzzSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                .fill(LinearGradient(colors: [Color(red: 1.0, green: 0.62, blue: 0.04),
                                              Color(red: 1.0, green: 0.84, blue: 0.04)],
                                     startPoint: .leading, endPoint: .trailing))
        )
        .shadow(color: Color(red: 1.0, green: 0.62, blue: 0.04).opacity(0.5), radius: 12, y: 4)
    }
}
