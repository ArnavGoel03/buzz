import Foundation

/// Lifecycle state of a Membership. Separating `pending` from `active` prevents orgs from
/// silently adding anyone as a member — users must explicitly accept an invitation.
enum MembershipStatus: String, Codable, CaseIterable, Hashable, Sendable {
    case pending            // officer invited this user; awaiting their acceptance
    case active             // accepted; badge displays on their profile
    case declined           // user rejected the invitation
    case revoked            // an officer removed the member
    case resigned           // member left the org voluntarily
}
