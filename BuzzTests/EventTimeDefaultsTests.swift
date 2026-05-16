import XCTest
@testable import Buzz

/// Pin the "what time should this event start by default" contract. Officers post
/// events on autopilot — wrong defaults mean accidentally creating events at the wrong
/// hour or wrong day.
final class EventTimeDefaultsTests: XCTestCase {

    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return cal
    }()

    /// Locked at 14:10. defaultStart = 14:10 + 1h = 15:10 → rounded down to 15:00 (minute < 30).
    func test_defaultStart_roundsDownWhenMinuteUnderThirty() {
        let now = makeDate(hour: 14, minute: 10)
        let start = EventTimeDefaults.defaultStart(now: now, calendar: calendar)
        let comps = calendar.dateComponents([.hour, .minute], from: start)
        XCTAssertEqual(comps.hour, 15)
        XCTAssertEqual(comps.minute, 0)
    }

    /// 14:35 + 1h = 15:35 → rounded to 15:30 (minute >= 30).
    func test_defaultStart_roundsToHalfHourWhenMinuteAtOrAboveThirty() {
        let now = makeDate(hour: 14, minute: 35)
        let start = EventTimeDefaults.defaultStart(now: now, calendar: calendar)
        let comps = calendar.dateComponents([.hour, .minute], from: start)
        XCTAssertEqual(comps.hour, 15)
        XCTAssertEqual(comps.minute, 30)
    }

    /// 14:30 (boundary) + 1h = 15:30 → rounded to 15:30 (minute >= 30 is `.thirty`).
    func test_defaultStart_atExactlyThirtyMinuteMark() {
        let now = makeDate(hour: 14, minute: 30)
        let start = EventTimeDefaults.defaultStart(now: now, calendar: calendar)
        let comps = calendar.dateComponents([.hour, .minute], from: start)
        XCTAssertEqual(comps.hour, 15)
        XCTAssertEqual(comps.minute, 30)
    }

    func test_defaultEnd_isExactlyTwoHoursAfterDefaultStart() {
        let now = makeDate(hour: 14, minute: 10)
        let start = EventTimeDefaults.defaultStart(now: now, calendar: calendar)
        let end = EventTimeDefaults.defaultEnd(now: now, calendar: calendar)
        XCTAssertEqual(end.timeIntervalSince(start), 2 * 3600)
    }

    func test_defaultStart_preservesDay() {
        let now = makeDate(hour: 23, minute: 5) // 23:05 + 1h = 00:05 next day, rounded to 00:00 next day
        let start = EventTimeDefaults.defaultStart(now: now, calendar: calendar)
        // Should land on the day AFTER `now`. Ensure we didn't accidentally drop the day.
        XCTAssertGreaterThan(start, now)
        XCTAssertLessThanOrEqual(start.timeIntervalSince(now), 3600)
    }

    // MARK: helpers

    private func makeDate(hour: Int, minute: Int) -> Date {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 5
        comps.day = 1
        comps.hour = hour
        comps.minute = minute
        return calendar.date(from: comps)!
    }
}
