import SwiftUI

/// Reusable pill used by both time and category filter rows.
struct FilterChip: View {
    let label: String
    let icon: String?
    let tint: Color
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: BuzzSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .bold))
                }
                Text(label)
                    .font(BuzzFont.captionBold)
            }
            .foregroundStyle(isActive ? Color.black : BuzzColor.textPrimary)
            .padding(.horizontal, BuzzSpacing.md)
            .padding(.vertical, BuzzSpacing.sm)
            .background(
                Capsule()
                    .fill(isActive ? tint : Color.white.opacity(0.08))
            )
            .overlay(
                Capsule()
                    .stroke(isActive ? Color.clear : BuzzColor.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.18), value: isActive)
    }
}
