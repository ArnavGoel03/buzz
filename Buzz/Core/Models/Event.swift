import Foundation
import CoreLocation

struct Event: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var title: String
    var summary: String
    var category: EventCategory
    var startsAt: Date
    var endsAt: Date
    var location: EventLocation
    var hostName: String
    var organizationID: UUID?           // host org (links to Organization)
    var subCampus: String?              // e.g. "warren", "muir" — for residential college systems
    var timezone: String?               // IANA TZ of venue (e.g. "America/Los_Angeles"); nil = device default
    var visibility: EventVisibility?    // nil = publicEvent
    var hideAttendees: Bool?            // nil = false
    var capacity: Int?
    var rsvpCount: Int
    var imageURL: URL?
    var tags: [String]
    var isOfficial: Bool

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    var isLive: Bool {
        let now = Date()
        return now >= startsAt && now <= endsAt
    }

    var startsWithinHour: Bool {
        let interval = startsAt.timeIntervalSinceNow
        return interval > 0 && interval <= 3600
    }

    var isTonight: Bool {
        Calendar.current.isDateInToday(startsAt) || Calendar.current.isDateInToday(endsAt)
    }

    /// Time-density bucket that drives the urgency bar on event cards.
    /// Intentionally coarse so the visual reads at a glance, not a stopwatch.
    /// The ladder: LIVE > STARTING (≤30m) > SOON (≤24h) > UPCOMING > PAST.
    var urgency: EventUrgency {
        let now = Date()
        if now > endsAt { return .past }
        if now >= startsAt { return .live }
        let delta = startsAt.timeIntervalSince(now)
        if delta <= 30 * 60 { return .starting }
        if delta <= 24 * 3600 { return .soon }
        return .upcoming
    }
}

enum EventUrgency: String, Sendable {
    case live, starting, soon, upcoming, past
}

struct EventLocation: Codable, Hashable, Sendable {
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
}
