import SwiftUI

/// Distinct verification for campus official departments (CAPS, Dining, Athletics, etc.)
/// vs regular verified student orgs. Builds trust that this really is the university
/// speaking, not a lookalike impersonator.
struct OfficialAccountBadge: View {
    let kind: Kind

    enum Kind: String {
        case department, athletics, dining, safety, housing, library, caps, admin

        var label: String {
            switch self {
            case .department: "Campus Department"
            case .athletics: "Athletics"
            case .dining: "Dining Services"
            case .safety: "Campus Safety"
            case .housing: "Housing"
            case .library: "Library"
            case .caps: "Counseling (CAPS)"
            case .admin: "University"
            }
        }

        var icon: String {
            switch self {
            case .department, .admin: "building.columns.fill"
            case .athletics: "sportscourt.fill"
            case .dining: "fork.knife"
            case .safety: "shield.lefthalf.filled"
            case .housing: "house.fill"
            case .library: "books.vertical.fill"
            case .caps: "heart.text.square.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: BuzzSpacing.xs) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
            Image(systemName: kind.icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
            Text(kind.label.uppercased())
                .font(BuzzFont.micro)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, BuzzSpacing.sm)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(LinearGradient(
                colors: [Color(red: 0.2, green: 0.5, blue: 1.0), Color(red: 0.1, green: 0.3, blue: 0.8)],
                startPoint: .leading, endPoint: .trailing
            ))
        )
    }
}
