import SwiftUI

/// Small pill summarizing a single affiliation — e.g. "UCSD · Warren · Sophomore".
/// Multiple affiliations (dual enrollment, study abroad, etc.) are shown as a horizontal row of these.
struct AffiliationPill: View {
    let affiliation: CampusAffiliation
    var isPrimary: Bool = false

    var body: some View {
        HStack(spacing: BuzzSpacing.xs) {
            if isPrimary {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 11, weight: .bold))
            }
            Text(summary)
                .font(BuzzFont.captionBold)
        }
        .foregroundStyle(isPrimary ? Color.black : BuzzColor.textPrimary)
        .padding(.horizontal, BuzzSpacing.sm)
        .padding(.vertical, 5)
        .background(Capsule().fill(isPrimary ? BuzzColor.accent : Color.white.opacity(0.08)))
        .overlay(Capsule().stroke(BuzzColor.border, lineWidth: isPrimary ? 0 : 1))
    }

    private var summary: String {
        var parts: [String] = [CampusRegistry.displayName(for: affiliation.campus)]
        if let sub = affiliation.subCampus {
            parts.append(CampusRegistry.subCampusName(affiliation.campus, sub))
        }
        if let year = affiliation.year { parts.append(year.displayName) }
        if let major = affiliation.major { parts.append(major) }
        return parts.joined(separator: " · ")
    }
}
