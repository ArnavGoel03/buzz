import Foundation
import CoreLocation

actor MockEventRepository: EventRepository {
    private var events: [Event]
    private var rsvps: [UUID: RSVPStatus] = [:]

    // Deterministic friend pool for social-proof previews. In prod this is replaced by a
    // join on `friendships` + `event_rsvps`; we pick per-event using a stable hash so the
    // same event always shows the same faces across app launches.
    private static let friendPool: [Profile] = [
        Self.stub(id: "F1E7D100-0001-4000-8000-000000000001", name: "Maya Patel",    handle: "mayap",      accent: "#FF2D92"),
        Self.stub(id: "F1E7D100-0001-4000-8000-000000000002", name: "Jordan Kim",    handle: "jkim",       accent: "#30D158"),
        Self.stub(id: "F1E7D100-0001-4000-8000-000000000003", name: "Ava Chen",      handle: "avac",       accent: "#0A84FF"),
        Self.stub(id: "F1E7D100-0001-4000-8000-000000000004", name: "Diego Ruiz",    handle: "diego",      accent: "#FF9500"),
        Self.stub(id: "F1E7D100-0001-4000-8000-000000000005", name: "Sana Qureshi",  handle: "sana",       accent: "#BF5AF2"),
        Self.stub(id: "F1E7D100-0001-4000-8000-000000000006", name: "Leo Nakamura",  handle: "leon",       accent: "#FFD60A"),
    ]

    private static func stub(id: String, name: String, handle: String, accent: String) -> Profile {
        Profile(
            id: UUID(uuidString: id)!,
            displayName: name,
            handle: "@\(handle)",
            pronouns: nil,
            bio: nil,
            avatarURL: nil,
            accentHex: accent,
            affiliations: [],
            primaryAffiliationID: nil
        )
    }

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

    func friendsGoing(eventID: UUID) async throws -> [Profile] {
        try? await Task.sleep(for: .milliseconds(40))
        // VULN #44 mirror: hidden-attendee events do not leak RSVPs even for friends.
        guard let event = events.first(where: { $0.id == eventID }) else { return [] }
        if event.hideAttendees == true { return [] }
        let pool = Self.friendPool
        // Stable hash → deterministic subset. Same event always shows the same friends.
        let seed = abs(eventID.uuidString.hashValue)
        let count = min(pool.count, seed % (pool.count + 1))
        guard count > 0 else { return [] }
        let start = seed % pool.count
        return (0..<count).map { pool[(start + $0) % pool.count] }
    }

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
