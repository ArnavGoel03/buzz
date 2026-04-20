import Foundation

protocol OrganizationRepository: Sendable {
    func organizations(campus: String) async throws -> [Organization]
    func organization(id: UUID) async throws -> Organization?
    func members(of organizationID: UUID) async throws -> [(Profile, Membership)]
    func searchProfiles(query: String, campus: String, limit: Int) async throws -> [Profile]
    func invite(profileID: UUID, to organizationID: UUID, role: MembershipRole, by inviterID: UUID) async throws
    func revoke(membershipID: UUID) async throws
}
