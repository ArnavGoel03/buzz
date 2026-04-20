import Foundation

extension Date {
    /// Human-friendly countdown: "Live now", "in 24m", "in 2h", "Tomorrow 8PM", "Fri 7PM".
    /// VULN #88 patch: respects the venue's IANA timezone so cross-region viewers don't
    /// misread when an event starts. Suffixes "(in NY time)" when the venue TZ differs
    /// from the user's so they can correctly convert.
    func friendlyStart(relativeTo now: Date = Date(), venueTimeZone: String? = nil) -> String {
        let interval = timeIntervalSince(now)
        if interval <= 0 { return "Live now" }
        if interval < 60 { return "Starting now" }
        if interval < 3600 { return "in \(Int(interval / 60))m" }
        if interval < 3600 * 6 { return "in \(Int(interval / 3600))h" }

        let venueTZ = venueTimeZone.flatMap(TimeZone.init(identifier:)) ?? .current
        var cal = Calendar.current
        cal.timeZone = venueTZ
        let df = DateFormatter()
        df.locale = Locale.current
        df.timeZone = venueTZ
        let suffix = (venueTZ.identifier != TimeZone.current.identifier)
            ? " (\(venueTZ.abbreviation() ?? venueTZ.identifier))"
            : ""

        if cal.isDateInToday(self) {
            df.dateFormat = "h:mm a"
            return df.string(from: self) + suffix
        }
        if cal.isDateInTomorrow(self) {
            df.dateFormat = "h:mm a"
            return "Tomorrow " + df.string(from: self) + suffix
        }
        df.dateFormat = "EEE h:mm a"
        return df.string(from: self) + suffix
    }
}
