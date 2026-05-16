import Foundation

/// Pure helpers for the "what time should this event start by default" logic. Extracted
/// from `CreateEventSheet` so the rounding behaviour can be unit-tested without
/// instantiating SwiftUI state.
enum EventTimeDefaults {
    /// One hour from `now`, rounded down to the nearest :00 or :30. The event creator
    /// usually wants "in about an hour" and round numbers read better in the UI.
    static func defaultStart(now: Date = Date(), calendar: Calendar = .current) -> Date {
        let future = now.addingTimeInterval(3600)
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: future)
        var rounded = comps
        rounded.minute = (comps.minute ?? 0) >= 30 ? 30 : 0
        return calendar.date(from: rounded) ?? future
    }

    /// Two hours after the default start — average campus event length.
    static func defaultEnd(now: Date = Date(), calendar: Calendar = .current) -> Date {
        defaultStart(now: now, calendar: calendar).addingTimeInterval(7200)
    }
}
