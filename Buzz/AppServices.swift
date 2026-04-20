import Foundation
import Observation

/// Central bag of shared services, injected into the view tree via `.environment`.
/// Swap `repository` for `SupabaseEventRepository` once the backend is wired up.
@Observable
@MainActor
final class AppServices {
    private(set) var events: EventRepository
    private(set) var orgs: OrganizationRepository
    private(set) var profiles: ProfileRepository
    let location: LocationService
    let network: NetworkMonitor
    let calendar: CalendarService

    init(
        events: EventRepository = MockEventRepository(),
        orgs: OrganizationRepository = MockOrganizationRepository(),
        profiles: ProfileRepository = MockProfileRepository(),
        location: LocationService = LocationService(),
        network: NetworkMonitor = NetworkMonitor(),
        calendar: CalendarService = CalendarService()
    ) {
        self.events = events
        self.orgs = orgs
        self.profiles = profiles
        self.location = location
        self.network = network
        self.calendar = calendar
    }

    /// VULN #82 patch: rebuild data repositories on auth identity change. Otherwise
    /// repositories cache the previous user's data in memory and keep serving it after
    /// sign-out / account switch. Mock builds reset to the same mock data; production
    /// rebuilds with the new session token.
    func resetForAccountSwitch() {
        events = MockEventRepository()
        orgs = MockOrganizationRepository()
        profiles = MockProfileRepository()
    }
}
