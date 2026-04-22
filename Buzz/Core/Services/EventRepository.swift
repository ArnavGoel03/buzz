import Foundation
import CoreLocation

protocol EventRepository: Sendable {
    func events(near coordinate: CLLocationCoordinate2D, radiusMeters: Double) async throws -> [Event]
    func event(id: UUID) async throws -> Event?
    func rsvp(eventID: UUID, status: RSVPStatus) async throws
    func myRSVPs() async throws -> [UUID: RSVPStatus]
    func createEvent(_ event: Event) async throws -> Event
    /// Friends of the current user who have RSVP'd "going" to this event. Production query
    /// joins `friendships` + `event_rsvps` and is RLS-gated per VULN #44 (no leaking RSVPs
    /// from hidden-attendee events). Default impl returns [] so non-mock repos are free to
    /// opt in incrementally.
    func friendsGoing(eventID: UUID) async throws -> [Profile]
}

extension EventRepository {
    func friendsGoing(eventID: UUID) async throws -> [Profile] { [] }
}
