import SwiftUI

/// Rim-lit gradient border + subtle inner highlight used on premium cards. Mirrors
/// the `.rim` class on the web — the detail that separates "designed" from "default".
struct RimCard: ViewModifier {
    var corner: CGFloat = BuzzSpacing.cornerLarge

    func body(content: Content) -> some View {
        content
            .background(BuzzColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.24),
                                Color.white.opacity(0.04),
                                Color.white.opacity(0.18)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

extension View {
    func rimCard(corner: CGFloat = BuzzSpacing.cornerLarge) -> some View {
        modifier(RimCard(corner: corner))
    }
}
