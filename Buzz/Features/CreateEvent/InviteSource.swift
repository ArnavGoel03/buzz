import Foundation

/// A "source" is one tap that adds N users to the invite list. Sources are stackable —
/// an event can be opened to "all board members + RSVPs from last rush event + a
/// hand-picked person" in three chips. De-duping happens at resolve time.
enum InviteSource: Hashable, Sendable {
    case allMembers(orgID: UUID, memberCount: Int)
    case boardOnly(orgID: UUID, boardCount: Int)
    case pastEventRSVPs(eventID: UUID, eventTitle: String, rsvpCount: Int)
    case customPerson(profileID: UUID, displayName: String, email: String)

    var label: String {
        switch self {
        case .allMembers(_, let n):            "All members · \(n)"
        case .boardOnly(_, let n):             "Board · \(n)"
        case .pastEventRSVPs(_, let t, let n): "From \"\(t)\" · \(n)"
        case .customPerson(_, let n, _):       n
        }
    }

    var icon: String {
        switch self {
        case .allMembers:      "person.3.fill"
        case .boardOnly:       "star.square.fill"
        case .pastEventRSVPs:  "calendar.badge.checkmark"
        case .customPerson:    "person.fill"
        }
    }
}
