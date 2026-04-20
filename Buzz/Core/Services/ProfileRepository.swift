import Foundation

protocol ProfileRepository: Sendable {
    func currentProfile() async throws -> Profile
    func memberships(for profileID: UUID) async throws -> [Membership]
    func setBadgeVisibility(membershipID: UUID, isVisible: Bool) async throws
    func respond(to membershipID: UUID, accept: Bool) async throws
}
