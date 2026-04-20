import XCTest
@testable import Buzz

final class EventTests: XCTestCase {
    func test_isLive_returnsTrueDuringWindow() {
        let event = makeEvent(startsIn: -300, duration: 3600)
        XCTAssertTrue(event.isLive)
    }

    func test_isLive_returnsFalseBeforeStart() {
        let event = makeEvent(startsIn: 300, duration: 3600)
        XCTAssertFalse(event.isLive)
    }

    func test_startsWithinHour() {
        let soon = makeEvent(startsIn: 1500, duration: 3600)
        let later = makeEvent(startsIn: 7200, duration: 3600)
        XCTAssertTrue(soon.startsWithinHour)
        XCTAssertFalse(later.startsWithinHour)
    }

    // MARK: helpers
    private func makeEvent(startsIn seconds: TimeInterval, duration: TimeInterval) -> Event {
        Event(
            id: UUID(),
            title: "Test", summary: "",
            category: .party,
            startsAt: Date().addingTimeInterval(seconds),
            endsAt: Date().addingTimeInterval(seconds + duration),
            location: EventLocation(name: "X", address: nil, latitude: 0, longitude: 0),
            hostName: "H", organizationID: nil, subCampus: nil,
            capacity: nil, rsvpCount: 0, imageURL: nil,
            tags: [], isOfficial: false
        )
    }
}
