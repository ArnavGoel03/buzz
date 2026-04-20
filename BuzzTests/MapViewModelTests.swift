import XCTest
import CoreLocation
@testable import Buzz

@MainActor
final class MapViewModelTests: XCTestCase {
    func test_filteredEvents_filtersByTime() async {
        let vm = MapViewModel(repository: StubRepo(events: [
            event(title: "Now", in: -60, duration: 1800),
            event(title: "Later", in: 86_400 * 3, duration: 3600),
        ]))
        await vm.load(near: .init(latitude: 0, longitude: 0))

        vm.timeFilter = .now
        XCTAssertEqual(vm.filteredEvents.map(\.title), ["Now"])

        vm.timeFilter = .week
        XCTAssertEqual(Set(vm.filteredEvents.map(\.title)), Set(["Now", "Later"]))
    }

    func test_toggleCategory_addsAndRemoves() async {
        let vm = MapViewModel(repository: StubRepo(events: []))
        vm.toggleCategory(.party)
        XCTAssertTrue(vm.categoryFilter.contains(.party))
        vm.toggleCategory(.party)
        XCTAssertFalse(vm.categoryFilter.contains(.party))
    }

    // MARK: helpers
    private func event(title: String, in seconds: TimeInterval, duration: TimeInterval) -> Event {
        Event(
            id: UUID(), title: title, summary: "",
            category: .party,
            startsAt: Date().addingTimeInterval(seconds),
            endsAt: Date().addingTimeInterval(seconds + duration),
            location: EventLocation(name: "X", address: nil, latitude: 0, longitude: 0),
            hostName: "H", organizationID: nil, subCampus: nil,
            capacity: nil, rsvpCount: 0, imageURL: nil, tags: [], isOfficial: false
        )
    }
}

private struct StubRepo: EventRepository {
    let events: [Event]
    func events(near coordinate: CLLocationCoordinate2D, radiusMeters: Double) async throws -> [Event] { events }
    func event(id: UUID) async throws -> Event? { events.first(where: { $0.id == id }) }
    func rsvp(eventID: UUID, status: RSVPStatus) async throws {}
    func myRSVPs() async throws -> [UUID: RSVPStatus] { [:] }
    func createEvent(_ event: Event) async throws -> Event { event }
}
