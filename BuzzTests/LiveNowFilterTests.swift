import XCTest
@testable import Buzz

/// Boundary tests for the "Bored Right Now" filter. Regression-prone: a careless
/// `>=` swap makes already-live events disappear, and a wrong window means push
/// notifications fire too early or too late.
final class LiveNowFilterTests: XCTestCase {

    private let now = Date(timeIntervalSinceReferenceDate: 700_000_000) // fixed reference
    private let window = LiveNowFilter.defaultWindow                    // 30 min

    func test_includesLiveEvents() {
        let live = event(title: "Live", startsAt: now.addingTimeInterval(-60), duration: 3600)
        let result = LiveNowFilter.filter([live], now: now, window: window)
        XCTAssertEqual(result.map(\.title), ["Live"])
    }

    func test_includesEventStartingWithinWindow() {
        let soon = event(title: "Soon", startsAt: now.addingTimeInterval(900), duration: 3600)
        let result = LiveNowFilter.filter([soon], now: now, window: window)
        XCTAssertEqual(result.map(\.title), ["Soon"])
    }

    func test_excludesEventStartingExactlyAtWindowEdge() {
        // Filter uses strict `<` against `now + window`, so an event starting exactly at
        // `now + 30 min` is excluded. Pin the contract — flipping to `<=` would let a
        // 30-min-out event pop into the live tab.
        let edge = event(title: "Edge", startsAt: now.addingTimeInterval(window), duration: 3600)
        let result = LiveNowFilter.filter([edge], now: now, window: window)
        XCTAssertEqual(result, [])
    }

    func test_excludesEventBeyondWindow() {
        let later = event(title: "Later", startsAt: now.addingTimeInterval(7200), duration: 3600)
        let result = LiveNowFilter.filter([later], now: now, window: window)
        XCTAssertEqual(result, [])
    }

    func test_excludesPastEvents() {
        let past = event(title: "Past", startsAt: now.addingTimeInterval(-7200), duration: 3600)
        let result = LiveNowFilter.filter([past], now: now, window: window)
        XCTAssertEqual(result, [])
    }

    func test_resultIsSortedAscendingByStart() {
        let a = event(title: "A", startsAt: now.addingTimeInterval(900), duration: 3600)
        let b = event(title: "B", startsAt: now.addingTimeInterval(300), duration: 3600)
        let c = event(title: "C", startsAt: now.addingTimeInterval(-60), duration: 3600)
        let result = LiveNowFilter.filter([a, b, c], now: now, window: window)
        XCTAssertEqual(result.map(\.title), ["C", "B", "A"])
    }

    func test_emptyInputReturnsEmptyOutput() {
        XCTAssertEqual(LiveNowFilter.filter([], now: now, window: window), [])
    }

    func test_eventStartingAtExactlyNow_isLiveNotSoon() {
        // `Event.isLiveAt(now)` uses `now >= startsAt`, so an event starting at this exact
        // instant counts as live, not "starting in <window>". Either way it's included,
        // but if `isLiveAt` regressed to strict `>` we'd want the test to point straight
        // at the live branch.
        let onTime = event(title: "OnTime", startsAt: now, duration: 3600)
        XCTAssertTrue(onTime.isLiveAt(now))
        XCTAssertEqual(LiveNowFilter.filter([onTime], now: now, window: window).map(\.title), ["OnTime"])
    }

    // MARK: helpers

    private func event(title: String, startsAt: Date, duration: TimeInterval) -> Event {
        Event(
            id: UUID(), title: title, summary: "",
            category: .party,
            startsAt: startsAt,
            endsAt: startsAt.addingTimeInterval(duration),
            location: EventLocation(name: "X", address: nil, latitude: 0, longitude: 0),
            hostName: "H", organizationID: nil, subCampus: nil,
            capacity: nil, rsvpCount: 0, imageURL: nil,
            tags: [], isOfficial: false
        )
    }
}
