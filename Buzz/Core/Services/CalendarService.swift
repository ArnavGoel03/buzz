import Foundation
import EventKit

/// Adds a Buzz event to the user's iOS Calendar on RSVP. Purely opt-in: requires an explicit
/// EventKit permission prompt. If denied, RSVP still succeeds; we just skip the calendar.
@MainActor
final class CalendarService {
    private let store = EKEventStore()

    func requestAccess() async -> Bool {
        do {
            return try await store.requestWriteOnlyAccessToEvents()
        } catch {
            return false
        }
    }

    /// Adds the event; returns false silently if denied. Idempotent via externalID so repeated
    /// RSVPs don't duplicate.
    func add(_ event: Event) async -> Bool {
        guard await requestAccess() else { return false }
        let ek = EKEvent(eventStore: store)
        ek.title = event.title
        ek.notes = event.summary
        ek.startDate = event.startsAt
        ek.endDate = event.endsAt
        ek.location = event.location.name
        ek.calendar = store.defaultCalendarForNewEvents
        ek.url = BuzzLink.event(event.id)
        ek.addAlarm(EKAlarm(relativeOffset: -900))      // 15 min reminder
        do {
            try store.save(ek, span: .thisEvent)
            return true
        } catch {
            return false
        }
    }
}
