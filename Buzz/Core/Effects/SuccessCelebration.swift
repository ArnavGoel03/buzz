import SwiftUI

/// Full-screen, one-second celebration. Fires on badge-unlock, streak milestone,
/// first-RSVP, ticket-purchased, rush-day-matched. Big check + scale-in + confetti +
/// heavy haptic + dismiss on tap or 1.2s timeout.
struct SuccessCelebration: View {
    let title: String
    let subtitle: String
    let tint: Color
    let onDismiss: () -> Void

    @State private var animateIn = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            ConfettiBurst(tint: tint)
                .frame(width: 300, height: 300)

            VStack(spacing: BuzzSpacing.md) {
                ZStack {
                    Circle()
                        .fill(tint)
                        .frame(width: 110, height: 110)
                        .shadow(color: tint.opacity(0.7), radius: 30)
                    Image(systemName: "checkmark")
                        .font(.system(size: 54, weight: .heavy))
                        .foregroundStyle(.white)
                }
                .scaleEffect(animateIn ? 1.0 : 0.4)
                Text(title)
                    .font(BuzzFont.largeTitle)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BuzzSpacing.xl)
                Text(subtitle)
                    .font(BuzzFont.body)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BuzzSpacing.xl)
            }
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 30)
        }
        .onTapGesture { onDismiss() }
        .onAppear {
            Haptics.success()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) { animateIn = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { onDismiss() }
        }
    }
}

/// Convenience `.sheet(isPresented:)` + view-modifier form so callers can just write
/// `.celebrateSuccess(...)` and forget about the plumbing.
extension View {
    func celebrateSuccess(
        isShowing: Binding<Bool>,
        title: String,
        subtitle: String,
        tint: Color = BuzzColor.accent
    ) -> some View {
        self.overlay {
            if isShowing.wrappedValue {
                SuccessCelebration(title: title, subtitle: subtitle, tint: tint) {
                    isShowing.wrappedValue = false
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isShowing.wrappedValue)
    }
}
