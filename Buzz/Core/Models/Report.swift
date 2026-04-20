import Foundation

/// A user-submitted report about an event, organization, or profile. Goes into the
/// moderation queue; admin reviews + takes action (hide, ban, dismiss).
struct Report: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var reporterID: UUID
    var target: ReportTarget
    var reason: ReportReason
    var notes: String?
    var createdAt: Date
    var status: ReportStatus
}

enum ReportTarget: Hashable, Sendable, Codable {
    case event(UUID)
    case organization(UUID)
    case profile(UUID)
}

enum ReportReason: String, Codable, CaseIterable, Hashable, Sendable {
    case spam
    case harassment
    case hateSpeech
    case dangerous
    case impersonation
    case underage
    case inaccurate
    case other

    var displayName: String {
        switch self {
        case .spam: "Spam or misleading"
        case .harassment: "Harassment or bullying"
        case .hateSpeech: "Hate speech"
        case .dangerous: "Dangerous or illegal"
        case .impersonation: "Impersonating a real person or org"
        case .underage: "Underage students involved"
        case .inaccurate: "Wrong info (time, place, etc.)"
        case .other: "Something else"
        }
    }
}

enum ReportStatus: String, Codable, Hashable, Sendable {
    case pending
    case actioned
    case dismissed
}
