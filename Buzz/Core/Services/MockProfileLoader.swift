import Foundation

/// Shared payload loaded once and reused by the profile and organization repos so they agree
/// on the same set of memberships.
enum MockProfileLoader {
    struct Payload: Decodable, Sendable {
        let profile: Profile
        let memberships: [Membership]
    }

    static func load() -> Payload {
        if let url = Bundle.main.url(forResource: "mockProfile", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let payload = try? decoder.decode(Payload.self, from: data) {
            return payload
        }
        return fallback
    }

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    /// VULN #36 patch: stable UUIDs so tests / previews are deterministic across runs.
    private static let fallback: Payload = {
        let profileID = UUID(uuidString: "C0FFEE00-0001-4000-8000-000000000001")!
        let affiliationID = UUID(uuidString: "AFF00000-0001-4000-8000-00000000F001")!
        let profile = Profile(
            id: profileID, displayName: "Yash Goel", handle: "@yashgoel",
            pronouns: "he/him", bio: "CS @ UCSD.", avatarURL: nil, accentHex: "#FFD60A",
            affiliations: [CampusAffiliation(
                id: affiliationID, campus: "ucsd", subCampus: "warren",
                role: .student, program: .undergraduate, status: .active,
                year: .sophomore, major: "Computer Science", minors: [],
                verifiedAt: nil, verificationMethod: nil,
                startDate: nil, endDate: nil
            )],
            primaryAffiliationID: affiliationID
        )
        return Payload(profile: profile, memberships: [])
    }()
}
