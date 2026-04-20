import Foundation
import CoreLocation

protocol EventRepository: Sendable {
    func events(near coordinate: CLLocationCoordinate2D, radiusMeters: Double) async throws -> [Event]
    func event(id: UUID) async throws -> Event?
    func rsvp(eventID: UUID, status: RSVPStatus) async throws
    func myRSVPs() async throws -> [UUID: RSVPStatus]
    func createEvent(_ event: Event) async throws -> Event
}
