import Foundation
import Observation

@Observable
@MainActor
final class OrganizationViewModel {
    let organizationID: UUID
    var organization: Organization?
    var members: [(Profile, Membership)] = []
    var events: [Event] = []
    var isLoading = false
    var isFollowing = false     // local-only toggle for MVP; wire to Supabase later

    private let orgs: OrganizationRepository
    private let eventsRepo: EventRepository

    init(organizationID: UUID, orgs: OrganizationRepository, events: EventRepository) {
        self.organizationID = organizationID
        self.orgs = orgs
        self.eventsRepo = events
    }

    func load(near lat: Double, lng: Double) async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let org = orgs.organization(id: organizationID)
            async let mem = orgs.members(of: organizationID)
            async let allEvents = eventsRepo.events(
                near: .init(latitude: lat, longitude: lng),
                radiusMeters: 20_000
            )
            self.organization = try await org
            self.members = try await mem
            let all = try await allEvents
            let orgName = self.organization?.name
            self.events = all
                .filter { $0.organizationID == organizationID || $0.hostName == orgName }
                .sorted { $0.startsAt < $1.startsAt }
        } catch {
            // MVP: silent
        }
    }

    /// True when the current viewer is a President or Founder of this org and can manage members.
    func canManage(currentUserID: UUID) -> Bool {
        members.contains { profile, m in
            profile.id == currentUserID && m.role.tier == .prestige && m.isActive
        }
    }

    var membersSorted: [(Profile, Membership)] {
        members.sorted { a, b in
            let pa = a.1.role.tier.priority
            let pb = b.1.role.tier.priority
            if pa != pb { return pa < pb }
            return a.1.since < b.1.since
        }
    }
}

private extension BadgeTier {
    var priority: Int {
        switch self {
        case .prestige: 0
        case .officer: 1
        case .member: 2
        }
    }
}
