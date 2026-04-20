import SwiftUI

/// Visible counter shown on org pages and profile to celebrate paper-flyer replacement.
/// Doubles as marketing — students screenshot it and post to socials.
struct PaperSavedPill: View {
    let sheets: Double
    var compact: Bool = false

    var body: some View {
        HStack(spacing: BuzzSpacing.xs) {
            Image(systemName: "leaf.fill")
                .font(.system(size: compact ? 11 : 13, weight: .bold))
            Text(label)
                .font(compact ? BuzzFont.micro : BuzzFont.captionBold)
        }
        .foregroundStyle(Color.black)
        .padding(.horizontal, BuzzSpacing.sm)
        .padding(.vertical, compact ? 4 : 5)
        .background(Capsule().fill(Color(red: 0.65, green: 0.95, blue: 0.55)))
    }

    private var label: String {
        compact ? PaperImpact.friendly(sheets) : "\(PaperImpact.friendly(sheets)) saved"
    }
}
