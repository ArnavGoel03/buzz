import SwiftUI

/// Single meta row: icon + primary + optional secondary text.
struct EventMetaRow: View {
    let icon: String
    let primary: String
    let secondary: String?

    var body: some View {
        HStack(spacing: BuzzSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(BuzzColor.textSecondary)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 1) {
                Text(primary)
                    .font(BuzzFont.bodyEmphasis)
                    .foregroundStyle(BuzzColor.textPrimary)
                if let secondary {
                    Text(secondary)
                        .font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textSecondary)
                }
            }
            Spacer()
        }
    }
}
