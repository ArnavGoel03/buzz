import Foundation
import Observation
import CoreLocation

@Observable
@MainActor
final class ClubsViewModel {
    var all: [Organization] = []
    var query: String = ""
    var categoryFilter: OrganizationCategory?
    var isLoading = false
    /// Orgs with at least one event currently live or starting within 30 min.
    /// Drives the pulsing "buzzing" dot on ClubCard so the directory surfaces
    /// who's active right now, not who has the most members.
    var buzzingOrgIDs: Set<UUID> = []

    private let orgs: OrganizationRepository
    private let events: EventRepository

    init(orgs: OrganizationRepository, events: EventRepository) {
        self.orgs = orgs
        self.events = events
    }

    func load(campus: String, near: CLLocationCoordinate2D) async {
        isLoading = true
        defer { isLoading = false }
        do {
            self.all = try await orgs.organizations(campus: campus)
        } catch {
            // MVP: silent
        }
        // 10km window — "is this club buzzing on campus *right now*." Anything past
        // that is out-of-band for a discovery grid and would just add noise.
        if let nearby = try? await events.events(near: near, radiusMeters: 10_000) {
            buzzingOrgIDs = Set(nearby.compactMap { event -> UUID? in
                let u = event.urgency
                guard u == .live || u == .starting else { return nil }
                return event.organizationID
            })
        }
    }

    func isBuzzing(_ org: Organization) -> Bool { buzzingOrgIDs.contains(org.id) }

    var filtered: [Organization] {
        all.filter { org in
            if let cat = categoryFilter, org.category != cat { return false }
            if !query.isEmpty {
                let q = query.lowercased()
                return org.name.lowercased().contains(q)
                    || org.handle.lowercased().contains(q)
                    || org.tagline.lowercased().contains(q)
            }
            return true
        }
    }

    /// "Trending" is mocked as "highest member count" for MVP. Real impl: weekly RSVP growth.
    var trending: [Organization] {
        Array(all.sorted { $0.memberCount > $1.memberCount }.prefix(5))
    }
}
