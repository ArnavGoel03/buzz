import Foundation

actor MockProfileRepository: ProfileRepository {
    private var profile: Profile
    private var memberships: [Membership]

    init() {
        let payload = MockProfileLoader.load()
        self.profile = payload.profile
        self.memberships = payload.memberships
    }

    func currentProfile() async throws -> Profile {
        try? await Task.sleep(for: .milliseconds(60))
        return profile
    }

    func memberships(for profileID: UUID) async throws -> [Membership] {
        memberships.filter { $0.profileID == profileID }
    }

    func setBadgeVisibility(membershipID: UUID, isVisible: Bool) async throws {
        try? await Task.sleep(for: .milliseconds(40))
        guard let idx = memberships.firstIndex(where: { $0.id == membershipID }) else { return }
        memberships[idx].isVisible = isVisible
    }

    func respond(to membershipID: UUID, accept: Bool) async throws {
        // VULN #50 patch: only the invited user can respond. Mirrors server-side check.
        try? await Task.sleep(for: .milliseconds(60))
        guard let idx = memberships.firstIndex(where: { $0.id == membershipID }) else { return }
        guard memberships[idx].profileID == profile.id else {
            throw URLError(.userAuthenticationRequired)
        }
        guard memberships[idx].isPending else { return }
        memberships[idx].status = accept ? .active : .declined
        if !accept { memberships[idx].endedAt = Date() }
    }
}
