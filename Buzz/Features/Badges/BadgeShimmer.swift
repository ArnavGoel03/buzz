import SwiftUI

/// Subtle holographic sheen that oscillates across the card. Intentionally slow & low-opacity —
/// the prestige tier should feel like it's "alive," not like it's flashing.
struct BadgeShimmer: View {
    let tint: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    // VULN #40 patch: react to low-power-mode toggling at runtime, not just at view creation.
    @State private var lowPower: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled

    var body: some View {
        Group {
            if reduceMotion || lowPower || scenePhase != .active {
                // Static gradient — no battery / motion-sickness impact.
                LinearGradient(
                    colors: [tint.opacity(0.18), .clear],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: false)) { context in
                    let t = context.date.timeIntervalSinceReferenceDate
                    let phase = (sin(t * 0.6) + 1) / 2
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.00), location: max(0, phase - 0.35)),
                            .init(color: .white.opacity(0.18), location: phase),
                            .init(color: tint.opacity(0.22), location: min(1, phase + 0.15)),
                            .init(color: .white.opacity(0.00), location: min(1, phase + 0.4)),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blendMode(.plusLighter)
                }
            }
        }
        .allowsHitTesting(false)
        .onReceive(NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)) { _ in
            lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
}
