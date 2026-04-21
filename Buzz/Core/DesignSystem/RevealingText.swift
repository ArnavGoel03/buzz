import SwiftUI

/// Word-by-word blur + rise reveal on appearance. Mirrors the web's TextReveal —
/// giant serif headlines materialize instead of popping in. Uses `phaseAnimator`
/// per-word with a staggered delay so the reveal cascades left → right.
struct RevealingText: View {
    let text: String
    var font: Font = BuzzFont.displayXL
    var foreground: Color = BuzzColor.textPrimary
    var delay: TimeInterval = 0
    var stagger: TimeInterval = 0.06

    @State private var visible = false

    private var words: [String] {
        text.split(separator: " ").map(String.init)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                Text(word)
                    .font(font)
                    .foregroundStyle(foreground)
                    .kerning(-0.4)
                    .opacity(visible ? 1 : 0)
                    .blur(radius: visible ? 0 : 10)
                    .offset(y: visible ? 0 : 12)
                    .animation(
                        .smooth(duration: 0.7)
                            .delay(delay + TimeInterval(index) * stagger),
                        value: visible
                    )
            }
        }
        .onAppear { visible = true }
    }
}
