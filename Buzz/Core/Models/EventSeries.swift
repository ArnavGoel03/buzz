import SwiftUI

/// Multi-day programs. Orientation Week, Homecoming, Finals Wellness, Greek Philanthropy Week.
struct EventSeries: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var campus: String
    var name: String
    var description: String?
    var coverURL: URL?
    var accentHex: String
    var startsOn: Date
    var endsOn: Date
    var organizedByOrg: UUID?

    var accent: Color { Color(hex: accentHex) ?? .accentColor }

    var dateRange: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        let start = f.string(from: startsOn)
        f.dateFormat = Calendar.current.isDate(startsOn, equalTo: endsOn, toGranularity: .month) ? "d" : "MMM d"
        let end = f.string(from: endsOn)
        return "\(start) – \(end)"
    }
}
