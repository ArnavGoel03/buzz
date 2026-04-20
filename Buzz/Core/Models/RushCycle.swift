import Foundation

struct RushCycle: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var campus: String
    var name: String
    var startsOn: Date
    var endsOn: Date
    var kind: RushKind
}

enum RushKind: String, Codable, CaseIterable, Hashable, Sendable {
    case panhellenic, ifc, multicultural, nphc, pro

    var displayName: String {
        switch self {
        case .panhellenic: "Panhellenic (sororities)"
        case .ifc: "IFC (fraternities)"
        case .multicultural: "Multicultural Greek"
        case .nphc: "NPHC (Divine Nine)"
        case .pro: "Professional"
        }
    }
}

struct RushRound: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var cycleID: UUID
    var name: String
    var ordinal: Int
    var startsOn: Date
    var endsOn: Date
}

struct RushInterest: Codable, Hashable, Sendable {
    var cycleID: UUID
    var profileID: UUID
    var organizationID: UUID
    var rusheeRank: Int?
    var chapterMark: ChapterMark?
    var updatedAt: Date

    enum ChapterMark: String, Codable, CaseIterable, Hashable, Sendable {
        case interested, invited, bid, passed
    }
}
