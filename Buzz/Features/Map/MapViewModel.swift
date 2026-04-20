import Foundation
import CoreLocation
import Observation

@Observable
@MainActor
final class MapViewModel {
    var events: [Event] = []
    var selectedEventID: UUID?
    var timeFilter: TimeFilter = .tonight
    var categoryFilter: Set<EventCategory> = []
    var isLoading = false
    var rsvps: [UUID: RSVPStatus] = [:]

    /// Events with an RSVP mutation already in flight. Blocks rapid double-taps from
    /// racing server-side and letting a stale write win.
    private var inflight: Set<UUID> = []

    private let repository: EventRepository

    init(repository: EventRepository) {
        self.repository = repository
    }

    var filteredEvents: [Event] {
        events.filter { event in
            guard timeFilter.matches(event) else { return false }
            if !categoryFilter.isEmpty, !categoryFilter.contains(event.category) { return false }
            return true
        }
    }

    var selectedEvent: Event? {
        guard let id = selectedEventID else { return nil }
        return events.first(where: { $0.id == id })
    }

    func load(near coordinate: CLLocationCoordinate2D) async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let fetched = repository.events(near: coordinate, radiusMeters: 5000)
            async let fetchedRSVPs = repository.myRSVPs()
            self.events = try await fetched
            self.rsvps = try await fetchedRSVPs
        } catch {
            // MVP: silent failure. Replace with a toast/banner.
        }
    }

    func toggleCategory(_ category: EventCategory) {
        if categoryFilter.contains(category) {
            categoryFilter.remove(category)
        } else {
            categoryFilter.insert(category)
        }
    }

    func rsvp(to eventID: UUID, status: RSVPStatus) async {
        guard !inflight.contains(eventID) else { return }   // debounce rapid double-taps
        inflight.insert(eventID)
        defer { inflight.remove(eventID) }

        let prior = rsvps[eventID] ?? .notGoing
        rsvps[eventID] = status
        if let idx = events.firstIndex(where: { $0.id == eventID }) {
            if prior != .going, status == .going { events[idx].rsvpCount += 1 }
            if prior == .going, status != .going { events[idx].rsvpCount = max(0, events[idx].rsvpCount - 1) }
        }
        do {
            try await repository.rsvp(eventID: eventID, status: status)
        } catch {
            rsvps[eventID] = prior
            if let idx = events.firstIndex(where: { $0.id == eventID }) {
                if prior != .going, status == .going { events[idx].rsvpCount = max(0, events[idx].rsvpCount - 1) }
                if prior == .going, status != .going { events[idx].rsvpCount += 1 }
            }
        }
    }
}
