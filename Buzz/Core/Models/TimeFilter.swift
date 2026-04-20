import Foundation

enum TimeFilter: String, CaseIterable, Identifiable, Hashable {
    case now
    case tonight
    case tomorrow
    case week

    var id: String { rawValue }

    var label: String {
        switch self {
        case .now: "Now"
        case .tonight: "Tonight"
        case .tomorrow: "Tomorrow"
        case .week: "This Week"
        }
    }

    func matches(_ event: Event, reference: Date = Date()) -> Bool {
        let cal = Calendar.current
        switch self {
        case .now:
            return reference >= event.startsAt.addingTimeInterval(-1800) &&
                   reference <= event.endsAt
        case .tonight:
            return cal.isDateInToday(event.startsAt) || cal.isDateInToday(event.endsAt)
        case .tomorrow:
            return cal.isDateInTomorrow(event.startsAt)
        case .week:
            guard let weekEnd = cal.date(byAdding: .day, value: 7, to: reference) else { return false }
            return event.startsAt >= reference && event.startsAt <= weekEnd
        }
    }
}
