import SwiftUI

struct ClubSearchBar: View {
    @Binding var query: String

    var body: some View {
        HStack(spacing: BuzzSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(BuzzColor.textSecondary)
            TextField("Search clubs, Greek life, honor societies…", text: $query)
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textPrimary)
                .tint(BuzzColor.accent)
                .submitLabel(.search)
            if !query.isEmpty {
                Button {
                    Haptics.tap()
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(BuzzColor.textTertiary)
                }
            }
        }
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, BuzzSpacing.sm)
        .background(Capsule().fill(.ultraThinMaterial))
        .overlay(Capsule().stroke(BuzzColor.border, lineWidth: 1))
    }
}
