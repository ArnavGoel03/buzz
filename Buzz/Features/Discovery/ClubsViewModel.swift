import Foundation
import Observation

@Observable
@MainActor
final class ClubsViewModel {
    var all: [Organization] = []
    var query: String = ""
    var categoryFilter: OrganizationCategory?
    var isLoading = false

    private let orgs: OrganizationRepository

    init(orgs: OrganizationRepository) {
        self.orgs = orgs
    }

    func load(campus: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            self.all = try await orgs.organizations(campus: campus)
        } catch {
            // MVP: silent
        }
    }

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
