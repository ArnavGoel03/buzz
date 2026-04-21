import Foundation

/// Minimal person shape used by the invite search/list UI. Richer than Profile because
/// we show PID / graduating year / campus for disambiguating duplicate names.
struct InvitePerson: Identifiable, Hashable, Sendable {
    let id: UUID
    let displayName: String
    let handle: String
    let email: String
    let phone: String?
    let campus: String?
    let graduatingYear: Int?
    let avatarURL: URL?

    var disambiguator: String {
        [campus?.uppercased(), graduatingYear.map { "'\(String($0).suffix(2))" }]
            .compactMap { $0 }
            .joined(separator: " · ")
    }
}
