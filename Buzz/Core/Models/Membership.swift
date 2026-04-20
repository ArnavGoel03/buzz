import Foundation

struct Membership: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var profileID: UUID
    var organizationID: UUID
    var role: MembershipRole
    var status: MembershipStatus?       // nil = active (for back-compat with existing JSON)
    var since: Date
    var endedAt: Date?                  // nil while active; set when user steps down or transfers
    var isVisible: Bool                 // student-controlled per-badge visibility on their profile
    var invitedBy: UUID?                // officer who created the invitation; audit trail

    var isActive: Bool {
        endedAt == nil && (status ?? .active) == .active
    }

    var isPending: Bool {
        (status ?? .active) == .pending
    }
}
