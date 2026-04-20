import Foundation

actor MockOrganizationRepository: OrganizationRepository {
    private let organizations: [Organization]
    private var profiles: [Profile]
    private var memberships: [Membership]

    init() {
        self.organizations = MockOrganizationLoader.load()
        let payload = MockProfileLoader.load()
        self.profiles = [payload.profile]
        self.memberships = payload.memberships
    }

    func organizations(campus: String) async throws -> [Organization] {
        try? await Task.sleep(for: .milliseconds(80))
        return organizations.filter { $0.campus == campus }
    }

    func organization(id: UUID) async throws -> Organization? {
        organizations.first(where: { $0.id == id })
    }

    func members(of organizationID: UUID) async throws -> [(Profile, Membership)] {
        let relevant = memberships.filter { $0.organizationID == organizationID && $0.isActive }
        return relevant.compactMap { m in
            profiles.first(where: { $0.id == m.profileID }).map { ($0, m) }
        }
    }

    func searchProfiles(query: String, campus: String, limit: Int) async throws -> [Profile] {
        // VULN #55 patch: bounded result set.
        // VULN #68 patch: honor the campus filter — search results scoped to the org's campus.
        try? await Task.sleep(for: .milliseconds(120))
        let q = query.lowercased()
        return profiles
            .filter { p in
                guard p.affiliations.contains(where: { $0.campus == campus && $0.status == .active })
                else { return false }
                return p.displayName.lowercased().contains(q)
                    || p.handle.lowercased().contains(q)
            }
            .prefix(min(max(1, limit), 50))
            .map { $0 }
    }

    func invite(profileID: UUID, to organizationID: UUID, role: MembershipRole, by inviterID: UUID) async throws {
        // VULN #43 patch: validate inviter is an active President/Founder. Server RLS already
        // enforces this — mirroring locally surfaces UI gating bugs before they hit prod.
        let inviterIsOfficer = memberships.contains { m in
            m.profileID == inviterID && m.organizationID == organizationID
                && m.role.tier == .prestige && m.isActive
        }
        guard inviterIsOfficer else { throw URLError(.userAuthenticationRequired) }
        try? await Task.sleep(for: .milliseconds(80))
        memberships.append(Membership(
            id: UUID(), profileID: profileID, organizationID: organizationID,
            role: role, status: .pending, since: Date(), endedAt: nil,
            isVisible: true, invitedBy: inviterID
        ))
    }

    func revoke(membershipID: UUID) async throws {
        if let idx = memberships.firstIndex(where: { $0.id == membershipID }) {
            memberships[idx].status = .revoked
            memberships[idx].endedAt = Date()
        }
    }
}
