import Foundation
import CoreLocation

actor MockEventRepository: EventRepository {
    private var events: [Event]
    private var rsvps: [UUID: RSVPStatus] = [:]

    init() {
        self.events = MockEventLoader.load()
    }

    func events(near coordinate: CLLocationCoordinate2D, radiusMeters: Double) async throws -> [Event] {
        try? await Task.sleep(for: .milliseconds(120))  // simulate latency
        let origin = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return events.filter { event in
            let loc = CLLocation(latitude: event.location.latitude, longitude: event.location.longitude)
            return origin.distance(from: loc) <= radiusMeters
        }
    }

    func event(id: UUID) async throws -> Event? {
        events.first(where: { $0.id == id })
    }

    func rsvp(eventID: UUID, status: RSVPStatus) async throws {
        try? await Task.sleep(for: .milliseconds(80))
        let prior = rsvps[eventID] ?? .notGoing
        rsvps[eventID] = status
        guard let idx = events.firstIndex(where: { $0.id == eventID }) else { return }
        var event = events[idx]
        if prior != .going, status == .going { event.rsvpCount += 1 }
        if prior == .going, status != .going { event.rsvpCount = max(0, event.rsvpCount - 1) }
        events[idx] = event
    }

    func myRSVPs() async throws -> [UUID: RSVPStatus] { rsvps }

    func createEvent(_ event: Event) async throws -> Event {
        // VULN #77 patch: mirror server-side `strip_event_official`. Mocks must reject what
        // production rejects, otherwise dev never sees the bug.
        try? await Task.sleep(for: .milliseconds(120))
        var safe = event
        safe.isOfficial = false
        events.append(safe)
        return safe
    }
}
