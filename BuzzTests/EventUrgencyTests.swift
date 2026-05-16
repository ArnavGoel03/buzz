import XCTest
@testable import Buzz

/// Pin the urgency ladder. The ranking drives the urgency bar on event cards and the
/// `.starting` push-notification trigger; a regression here would silently change which
/// events feel urgent in the UI.
///
///   PAST < UPCOMING < SOON < STARTING < LIVE
final class EventUrgencyTests: XCTestCase {

    func test_live_whenNowIsBetweenStartAndEnd() {
        let event = makeEvent(startsIn: -300, duration: 3600)
        XCTAssertEqual(event.urgency, .live)
    }

    func test_live_atExactStart() {
        // The event starts at the same instant as `now`. `urgency` uses `>=` so this is live.
        let event = makeEvent(startsIn: 0, duration: 3600)
        XCTAssertEqual(event.urgency, .live)
    }

    func test_starting_when30MinutesOrLessAway() {
        // 25 min away: starting.
        let event = makeEvent(startsIn: 25 * 60, duration: 3600)
        XCTAssertEqual(event.urgency, .starting)
    }

    func test_starting_atExactly30MinuteBoundary() {
        // Exactly 30 min: still .starting (delta <= 30*60).
        let event = makeEvent(startsIn: 30 * 60, duration: 3600)
        XCTAssertEqual(event.urgency, .starting)
    }

    func test_soon_justAfterStartingBoundary() {
        // 30:01 min: tips into .soon.
        let event = makeEvent(startsIn: 30 * 60 + 1, duration: 3600)
        XCTAssertEqual(event.urgency, .soon)
    }

    func test_soon_within24Hours() {
        let event = makeEvent(startsIn: 12 * 3600, duration: 3600)
        XCTAssertEqual(event.urgency, .soon)
    }

    func test_upcoming_beyond24Hours() {
        let event = makeEvent(startsIn: 25 * 3600, duration: 3600)
        XCTAssertEqual(event.urgency, .upcoming)
    }

    func test_past_afterEnd() {
        let event = makeEvent(startsIn: -7200, duration: 3600) // started 2h ago, was 1h long
        XCTAssertEqual(event.urgency, .past)
    }

    func test_past_atExactlyEndPlusOneSecond() {
        // 3601s ago start, 3600s duration → ended 1s ago. Past.
        let event = makeEvent(startsIn: -3601, duration: 3600)
        XCTAssertEqual(event.urgency, .past)
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
