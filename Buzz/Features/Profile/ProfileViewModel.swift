import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    var profile: Profile?
    var memberships: [Membership] = []
    var orgsByID: [UUID: Organization] = [:]
    var isLoading = false
    var selectedMembershipID: UUID?
    var pendingOrgID: UUID?          // set when user taps "View organization" — RootView reads + clears

    private let profiles: ProfileRepository
    private let orgs: OrganizationRepository

    init(profiles: ProfileRepository, orgs: OrganizationRepository) {
        self.profiles = profiles
        self.orgs = orgs
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let me = try await profiles.currentProfile()
            self.profile = me
            self.memberships = try await profiles.memberships(for: me.id)
            let campus = me.primaryAffiliation?.campus ?? "ucsd"
            let allOrgs = try await orgs.organizations(campus: campus)
            self.orgsByID = Dictionary(uniqueKeysWithValues: allOrgs.map { ($0.id, $0) })
        } catch {
            // MVP: silent fail
        }
    }

    var selectedMembership: Membership? {
        guard let id = selectedMembershipID else { return nil }
        return memberships.first(where: { $0.id == id })
    }

    var pendingInvites: [Membership] {
        memberships.filter { $0.isPending }
    }

    var activeMemberships: [Membership] {
        memberships.filter { $0.isActive }
    }

    func setVisibility(_ isVisible: Bool, for membershipID: UUID) async {
        if let idx = memberships.firstIndex(where: { $0.id == membershipID }) {
            memberships[idx].isVisible = isVisible
        }
        try? await profiles.setBadgeVisibility(membershipID: membershipID, isVisible: isVisible)
    }

    func respondToInvite(_ membershipID: UUID, accept: Bool) async {
        // VULN #94 patch: rollback if the server rejects (stale officer privilege, race,
        // timeout). Without this, UI says "accepted" while the server is still pending.
        guard let idx = memberships.firstIndex(where: { $0.id == membershipID }) else { return }
        let priorStatus = memberships[idx].status
        let priorEndedAt = memberships[idx].endedAt
        memberships[idx].status = accept ? .active : .declined
        if !accept { memberships[idx].endedAt = Date() }
        do {
            try await profiles.respond(to: membershipID, accept: accept)
        } catch {
            memberships[idx].status = priorStatus
            memberships[idx].endedAt = priorEndedAt
        }
    }
}
