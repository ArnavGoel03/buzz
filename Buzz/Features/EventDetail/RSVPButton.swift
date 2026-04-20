import SwiftUI

struct RSVPButton: View {
    let status: RSVPStatus
    let tint: Color
    let onTap: (RSVPStatus) -> Void
    @State private var showConfetti = false

    var body: some View {
        ZStack(alignment: .top) {
            Button {
                let next: RSVPStatus = status == .going ? .notGoing : .going
                if next == .going {
                    Haptics.success()
                    showConfetti = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { showConfetti = false }
                } else {
                    Haptics.warning()
                }
                onTap(next)
            } label: {
                HStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: status == .going ? "checkmark.circle.fill" : "sparkles")
                        .font(.system(size: 18, weight: .bold))
                        .symbolEffect(.bounce, value: status)
                    Text(status == .going ? "You're going" : "Count me in")
                        .font(BuzzFont.headline)
                        .contentTransition(.identity)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BuzzSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                        .fill(status == .going ? tint : BuzzColor.accent)
                )
            }
            .buttonStyle(.springy)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: status)

            // Confetti origin above the button — visible moment of delight on commit.
            if showConfetti {
                ConfettiBurst(tint: tint)
                    .frame(width: 300, height: 200)
                    .offset(y: -140)
                    .allowsHitTesting(false)
            }
        }
    }
}
