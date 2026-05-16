import XCTest
@testable import Buzz

@MainActor
final class AppServicesResetTests: XCTestCase {

    /// VULN #82 — repos must be REPLACED on account switch, not just have caches cleared.
    /// If `resetForAccountSwitch` no-ops or only mutates the existing repo's state, the
    /// next user keeps seeing the previous user's data. Mock repos are actors (reference
    /// types) so `===` against the bridged AnyObject is stable.
    func test_resetForAccountSwitch_replacesAllRepositoryInstances() {
        let services = AppServices()
        let beforeEvents = services.events as AnyObject
        let beforeOrgs = services.orgs as AnyObject
        let beforeProfiles = services.profiles as AnyObject

        services.resetForAccountSwitch()

        XCTAssertFalse(beforeEvents === (services.events as AnyObject),
                       "EventRepository must be a fresh instance after account switch — VULN #82")
        XCTAssertFalse(beforeOrgs === (services.orgs as AnyObject),
                       "OrganizationRepository must be a fresh instance after account switch — VULN #82")
        XCTAssertFalse(beforeProfiles === (services.profiles as AnyObject),
                       "ProfileRepository must be a fresh instance after account switch — VULN #82")
    }

    /// Per-device singletons (location, network, calendar) intentionally survive reset
    /// — they're not user-scoped and re-creating them would force every user to re-grant
    /// location authorization on every account switch. Pin that contract too.
    func test_resetForAccountSwitch_keepsDeviceServicesStable() {
        let services = AppServices()
        let beforeLocation = services.location
        let beforeNetwork = services.network
        let beforeCalendar = services.calendar

        services.resetForAccountSwitch()

        XCTAssertTrue(beforeLocation === services.location)
        XCTAssertTrue(beforeNetwork === services.network)
        XCTAssertTrue(beforeCalendar === services.calendar)
    }
}
