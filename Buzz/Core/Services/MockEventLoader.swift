import Foundation

/// Loads seed events. Reads `mockEvents.json` from the bundle; falls back to a built-in sample
/// so previews and first-run always have something to render.
enum MockEventLoader {
    static func load() -> [Event] {
        if let url = Bundle.main.url(forResource: "mockEvents", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let events = try? Self.decoder.decode([Event].self, from: data) {
            return Self.rebased(events)
        }
        return Self.rebased(MockEventSeed.fallback)
    }

    /// Shifts hardcoded times so events are always "today/tomorrow" relative to now —
    /// keeps the MVP looking alive without touching the JSON.
    private static func rebased(_ events: [Event]) -> [Event] {
        let now = Date()
        let cal = Calendar.current
        guard let todayStart = cal.date(bySettingHour: 0, minute: 0, second: 0, of: now) else { return events }
        return events.map { event in
            var e = event
            let dayOffset = cal.dateComponents([.day], from: cal.startOfDay(for: event.startsAt), to: todayStart).day ?? 0
            if let newStart = cal.date(byAdding: .day, value: dayOffset, to: event.startsAt),
               let newEnd = cal.date(byAdding: .day, value: dayOffset, to: event.endsAt) {
                e.startsAt = newStart
                e.endsAt = newEnd
            }
            return e
        }
    }

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
