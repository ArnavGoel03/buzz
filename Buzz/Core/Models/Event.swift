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
}

struct EventLocation: Codable, Hashable, Sendable {
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
}
