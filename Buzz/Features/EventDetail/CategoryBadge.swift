import SwiftUI

struct CategoryBadge: View {
    let category: EventCategory
    let isOfficial: Bool

    var body: some View {
        HStack(spacing: BuzzSpacing.xs) {
            Image(systemName: category.icon)
                .font(.system(size: 11, weight: .bold))
            Text(category.shortName.uppercased())
                .font(BuzzFont.micro)
            if isOfficial {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 11, weight: .bold))
            }
        }
        .foregroundStyle(.black)
        .padding(.horizontal, BuzzSpacing.sm)
        .padding(.vertical, 5)
        .background(Capsule().fill(category.tint))
    }
}
