import SwiftUI

struct Profile: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var displayName: String
    var handle: String                          // e.g. "@yashgoel"
    var pronouns: String?
    var bio: String?
    var avatarURL: URL?
    var accentHex: String                       // gradient ring color; auto-derivable from name hash
    var affiliations: [CampusAffiliation]       // every campus they've ever verified at
    var primaryAffiliationID: UUID?             // drives default campus context across the app

    var accent: Color { Color(hex: accentHex) ?? .accentColor }

    var initials: String {
        let parts = displayName.split(separator: " ").prefix(2)
        return parts.compactMap { $0.first.map(String.init) }.joined().uppercased()
    }

    /// VULN #81 patch: canonical storage form is bare ("yashgoel"); UI display always
    /// prepends "@". Use this everywhere a handle is shown so we don't get "@@yashgoel"
    /// or "yashgoel" depending on storage origin.
    var displayHandle: String {
        let bare = handle.drop(while: { $0 == "@" }).trimmingCharacters(in: .whitespaces)
        // VULN #91 patch: empty handles fall back to a slugified display name so we never
        // render a bare "@".
        if bare.isEmpty {
            return "@" + displayName.lowercased().filter { $0.isLetter || $0.isNumber }
        }
        return "@" + bare
    }

    var primaryAffiliation: CampusAffiliation? {
        guard let id = primaryAffiliationID else { return affiliations.first }
        return affiliations.first(where: { $0.id == id }) ?? affiliations.first
    }

    var activeAffiliations: [CampusAffiliation] {
        affiliations.filter { $0.status == .active }
    }
}
