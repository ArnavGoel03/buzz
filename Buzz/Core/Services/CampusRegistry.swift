import Foundation

/// Static, read-only lookup of campuses. Seeded from `mockCampuses.json` today; swap in an
/// IPEDS-backed Supabase table later without touching callers.
@MainActor
enum CampusRegistry {
    private static var byID: [String: Campus] = {
        guard let url = Bundle.main.url(forResource: "mockCampuses", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let campuses = try? JSONDecoder().decode([Campus].self, from: data)
        else { return [:] }
        return Dictionary(uniqueKeysWithValues: campuses.map { ($0.id, $0) })
    }()

    static func campus(for id: String) -> Campus? { byID[id] }

    static func all() -> [Campus] {
        byID.values.sorted { $0.displayName < $1.displayName }
    }

    /// Used by the email-based campus picker during onboarding: infer campus from `.edu` domain.
    static func campus(matchingEmailDomain domain: String) -> Campus? {
        let d = domain.lowercased()
        return byID.values.first { $0.domains.contains(where: { d == $0 || d.hasSuffix("." + $0) }) }
    }

    static func displayName(for campusID: String) -> String {
        byID[campusID]?.shortName ?? campusID.uppercased()
    }

    static func subCampusName(_ campusID: String, _ subID: String) -> String {
        byID[campusID]?.subCampuses.first(where: { $0.id == subID })?.displayName ?? subID.capitalized
    }
}
