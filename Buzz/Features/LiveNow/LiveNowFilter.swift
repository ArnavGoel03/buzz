import Foundation

/// Pure filter for the "Bored Right Now" tab — events live OR starting in the next
/// `window` seconds. Extracted from `LiveNowView` so the boundary logic can be
/// unit-tested. Sorted ascending by start time.
enum LiveNowFilter {
    /// Default 30-minute look-ahead window matches the urgency `.starting` bucket.
    static let defaultWindow: TimeInterval = 30 * 60

    static func filter(
        _ events: [Event],
        now: Date = Date(),
        window: TimeInterval = LiveNowFilter.defaultWindow
    ) -> [Event] {
        events
            .filter { event in
                if event.isLiveAt(now) { return true }
                return event.startsAt > now && event.startsAt < now.addingTimeInterval(window)
            }
            .sorted { $0.startsAt < $1.startsAt }
    }
}

extension Event {
    /// `isLive` evaluated against an injectable `now`. Lets `LiveNowFilter` be tested
    /// without freezing real time. The view layer keeps using `event.isLive`.
    func isLiveAt(_ now: Date) -> Bool {
        now >= startsAt && now <= endsAt
    }
}
