import SwiftUI

/// "bu**zz**" kerned wordmark — italic serif Z with accent color. Distinctive
/// without leaning on a generic SF Symbol. Mirrors the web wordmark.
struct WordmarkView: View {
    var size: CGFloat = 22

    var body: some View {
        HStack(spacing: 0) {
            Text("bu")
                .font(.system(size: size, weight: .medium, design: .serif))
                .foregroundStyle(BuzzColor.textPrimary)
            Text("zz")
                .font(.system(size: size, weight: .medium, design: .serif).italic())
                .foregroundStyle(BuzzColor.accent)
        }
        .kerning(-0.8)
    }
}
