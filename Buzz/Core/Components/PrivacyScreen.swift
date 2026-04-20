import SwiftUI

/// Obscures sensitive content when the app is backgrounded so the iOS app-switcher snapshot
/// doesn't leak profile/RSVP/affiliation data. Apply to root containers — the modifier no-ops
/// while the scene is `.active`.
///
/// VULN #28 patch.
struct PrivacyScreen: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .overlay {
                if scenePhase != .active {
                    ZStack {
                        BuzzColor.background.ignoresSafeArea()
                        Image(systemName: "sparkles")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(BuzzColor.accent.opacity(0.5))
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: scenePhase)
    }
}

extension View {
    /// Hide sensitive content from the app-switcher snapshot. Apply to root AND to every
    /// sheet's root content — sheets render in their own window and bypass root overlays.
    /// VULN #75 patch.
    func privacyScreen() -> some View { modifier(PrivacyScreen()) }
}
