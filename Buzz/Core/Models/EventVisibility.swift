import Foundation

/// Per-event access scope. Prevents outsiders from finding/crashing student-only events,
/// and lets orgs run member-only gatherings without those showing up on the public map.
enum EventVisibility: String, Codable, CaseIterable, Hashable, Sendable {
    case publicEvent        // anyone on Buzz can see & RSVP
    case campusOnly         // only verified members of the host campus
    case memberOnly         // active members of the host organization
    case officersOnly       // officers / board of the host organization
    case inviteOnly         // only users on the explicit invite list

    var displayName: String {
        switch self {
        case .publicEvent:  "Public · anyone on Buzz"
        case .campusOnly:   "Everyone at my campus"
        case .memberOnly:   "Members of my club"
        case .officersOnly: "Board only"
        case .inviteOnly:   "Invite only"
        }
    }

    var icon: String {
        switch self {
        case .publicEvent:  "globe"
        case .campusOnly:   "building.columns"
        case .memberOnly:   "person.3.fill"
        case .officersOnly: "star.square.fill"
        case .inviteOnly:   "envelope.fill"
        }
    }
}
