import Foundation
import CoreLocation

/// Round 5 — scores an event for a specific user based on interests, friend graph,
/// past check-in history, proximity, and time fit. Replaces chronological sorting
/// with personalized ranking for the Live tab. Pure function, testable, no state.
struct EventRankerInput: Sendable {
    let event: Event
    let userCoord: CLLocationCoordinate2D
    let userInterests: [EventCategory: Double]          // weight per category from profile_interests
    let friendsGoingCount: Int
    let pastAttendanceByCategory: [EventCategory: Int]  // implicit signal
    let now: Date
}

enum EventRanker {
    /// Score ≥ 0. Higher = more relevant. Tune weights as we learn from real engagement data.
    static func score(_ input: EventRankerInput) -> Double {
        var score: Double = 0

        // 1. Interest match (0–5, explicit user preference)
        let interestWeight = input.userInterests[input.event.category] ?? 0
        score += interestWeight * 4.0

        // 2. Friend graph — strong signal for college social events
        score += min(Double(input.friendsGoingCount), 5) * 3.0

        // 3. Implicit category affinity — user always shows up to parties? Rank parties higher.
        let past = input.pastAttendanceByCategory[input.event.category] ?? 0
        score += min(Double(past), 10) * 0.5

        // 4. Proximity — walking distance beats a drive
        let dist = CLLocation(latitude: input.userCoord.latitude, longitude: input.userCoord.longitude)
            .distance(from: CLLocation(latitude: input.event.location.latitude, longitude: input.event.location.longitude))
        if dist < 400   { score += 6 }       // ~5 min walk
        else if dist < 1000 { score += 3 }   // ~15 min walk
        else if dist < 3000 { score += 1 }   // bike-able

        // 5. Time fit — live or starting soon beats "next week"
        let interval = input.event.startsAt.timeIntervalSince(input.now)
        if input.event.isLive              { score += 8 }
        else if interval < 3600            { score += 6 }    // < 1h
        else if interval < 3600 * 6        { score += 3 }    // < 6h (tonight)
        else if interval < 3600 * 24       { score += 1 }

        // 6. RSVP velocity — already-popular events likely good
        score += log2(Double(max(1, input.event.rsvpCount))) * 0.3

        // 7. Official/verified small boost
        if input.event.isOfficial { score += 1 }

        return max(0, score)
    }

    /// Rank a list; ties broken by start time.
    static func rank(_ events: [Event], for user: (CLLocationCoordinate2D, [EventCategory: Double], [UUID: Int], [EventCategory: Int])) -> [Event] {
        let now = Date()
        return events
            .map { event -> (Event, Double) in
                let friendsGoing = user.2[event.id] ?? 0
                let input = EventRankerInput(
                    event: event, userCoord: user.0, userInterests: user.1,
                    friendsGoingCount: friendsGoing,
                    pastAttendanceByCategory: user.3, now: now
                )
                return (event, score(input))
            }
            .sorted { a, b in
                if a.1 != b.1 { return a.1 > b.1 }
                return a.0.startsAt < b.0.startsAt
            }
            .map(\.0)
    }
}
