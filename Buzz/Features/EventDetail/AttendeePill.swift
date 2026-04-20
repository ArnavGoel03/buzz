import SwiftUI

struct AttendeePill: View {
    let count: Int
    let capacity: Int?

    var body: some View {
        HStack(spacing: BuzzSpacing.xs) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 11, weight: .bold))
            HStack(spacing: 2) {
                CountingInt(value: count, font: BuzzFont.captionBold)
                Text(suffix).font(BuzzFont.captionBold)
            }
        }
        .foregroundStyle(BuzzColor.textPrimary)
        .padding(.horizontal, BuzzSpacing.sm)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.white.opacity(0.10)))
    }

    private var suffix: String {
        if let capacity { return "/\(capacity)" }
        return " going"
    }
}
