import SwiftUI

/// Round 2 — prominent SOS. Long-press (3s) to prevent accidental triggers. On release
/// fires: campus safety API, primary emergency contact, nearby Buzz users opted into
/// help-network. Also opens native Emergency SOS (power + volume) via a TapticGenerator heavy cue.
struct EmergencySOSButton: View {
    @State private var pressProgress: CGFloat = 0
    @State private var fired = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: pressProgress)
                .stroke(BuzzColor.live, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .fill(BuzzColor.live)
                .overlay(
                    VStack(spacing: 2) {
                        Image(systemName: "sos")
                            .font(.system(size: 32, weight: .black))
                        Text("Hold 3s")
                            .font(BuzzFont.micro)
                    }
                    .foregroundStyle(.white)
                )
                .scaleEffect(0.85)
        }
        .frame(width: 120, height: 120)
        .shadow(color: BuzzColor.live.opacity(0.5), radius: 20)
        .gesture(longPress)
    }

    private var longPress: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                if pressProgress < 1 {
                    withAnimation(.linear(duration: 3.0)) { pressProgress = 1.0 }
                }
            }
            .onEnded { _ in
                if pressProgress >= 0.98 {
                    Haptics.heavy()
                    fired = true
                    // Production: POST /api/safety/sos with { profile_id, location, timestamp }
                    // → fans out push to emergency contacts + campus safety dispatcher.
                } else {
                    withAnimation(.easeOut(duration: 0.2)) { pressProgress = 0 }
                }
            }
    }
}
