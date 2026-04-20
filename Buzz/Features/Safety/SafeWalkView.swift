import SwiftUI
import MapKit

/// Round 2 — share your walk home with a friend. They see your live position until
/// you tap "Arrived." If you don't arrive in the estimated time + 5 min grace, the
/// buddy gets a nudge; if no response, we escalate to emergency contact.
struct SafeWalkView: View {
    let destinationName: String
    let buddy: Profile?
    @State private var isWalking = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            header
            Map().frame(height: 280).cornerRadius(BuzzSpacing.cornerMedium)
            statusCard
            Spacer()
            arrivedButton
        }
        .padding(BuzzSpacing.lg)
        .background(BuzzColor.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
            Text("Safe walk").font(BuzzFont.title)
            if let buddy {
                Text("\(buddy.displayName) is watching your walk to \(destinationName).")
                    .font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textSecondary)
            } else {
                Text("Walking to \(destinationName) alone? Pick a buddy.")
                    .font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusCard: some View {
        HStack(spacing: BuzzSpacing.md) {
            Image(systemName: "figure.walk.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(BuzzColor.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Live location shared").font(BuzzFont.bodyEmphasis)
                Text("Stops when you arrive or cancel.").font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textSecondary)
            }
            Spacer()
        }
        .padding(BuzzSpacing.md)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }

    private var arrivedButton: some View {
        Button {
            Haptics.success()
            isWalking = false
            dismiss()
        } label: {
            Text("I'm here, end walk")
                .font(BuzzFont.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BuzzSpacing.md)
                .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.accent))
        }
        .buttonStyle(.plain)
    }
}
