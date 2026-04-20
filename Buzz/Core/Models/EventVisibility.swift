import Foundation

/// Per-event access scope. Prevents outsiders from finding/crashing student-only events,
/// and lets orgs run member-only gatherings without those showing up on the public map.
enum EventVisibility: String, Codable, CaseIterable, Hashable, Sendable {
    case publicEvent        // anyone on Buzz can see & RSVP
    case campusOnly         // only verified members of the host campus
    case inviteOnly         // only users the host adds or who have the direct link
    case officersOnly       // internal org planning events — not visible to general members
}
