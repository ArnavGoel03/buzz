import XCTest
@testable import Buzz

@MainActor
final class UniversalLinkRouterTests: XCTestCase {

    // MARK: routing — happy paths

    func test_handle_eventURL_setsPendingEventID() throws {
        let router = UniversalLinkRouter()
        let id = UUID()
        router.handle(BuzzLink.event(id))
        XCTAssertEqual(router.pendingEventID, id)
        XCTAssertNil(router.pendingOrgHandle)
        XCTAssertNil(router.pendingProfileHandle)
    }

    func test_handle_orgURL_setsPendingOrgHandle() {
        let router = UniversalLinkRouter()
        router.handle(BuzzLink.organization(handle: "sigma-phi"))
        XCTAssertEqual(router.pendingOrgHandle, "sigma-phi")
        XCTAssertNil(router.pendingEventID)
        XCTAssertNil(router.pendingProfileHandle)
    }

    func test_handle_profileURL_setsPendingProfileHandle() {
        let router = UniversalLinkRouter()
        router.handle(BuzzLink.profile(handle: "@alex"))
        // VULN #84 patch — leading "@" should be stripped before storing.
        XCTAssertEqual(router.pendingProfileHandle, "alex")
    }

    // MARK: VULN #58 — consume must nilify

    func test_consumeEvent_returnsValueOnceAndThenNil() {
        let router = UniversalLinkRouter()
        let id = UUID()
        router.handle(BuzzLink.event(id))
        XCTAssertEqual(router.consumeEvent(), id)
        XCTAssertNil(router.consumeEvent(), "Second consume must return nil — VULN #58 prevents navigation re-trigger loops")
        XCTAssertNil(router.pendingEventID)
    }

    func test_consumeOrganization_clearsAfterRead() {
        let router = UniversalLinkRouter()
        router.handle(BuzzLink.organization(handle: "founders-club"))
        XCTAssertEqual(router.consumeOrganization(), "founders-club")
        XCTAssertNil(router.consumeOrganization())
    }

    func test_consumeProfile_clearsAfterRead() {
        let router = UniversalLinkRouter()
        router.handle(BuzzLink.profile(handle: "alex"))
        XCTAssertEqual(router.consumeProfile(), "alex")
        XCTAssertNil(router.consumeProfile())
    }

    // MARK: hostile / malformed inputs

    func test_handle_otherDomain_isIgnored() {
        let router = UniversalLinkRouter()
        let phish = URL(string: "https://buzz.app.evil.example/e/\(UUID().uuidString)")!
        router.handle(phish)
        XCTAssertNil(router.pendingEventID)
    }

    func test_handle_httpScheme_isIgnored() {
        let router = UniversalLinkRouter()
        let insecure = URL(string: "http://buzz.app/e/\(UUID().uuidString)")!
        router.handle(insecure)
        XCTAssertNil(router.pendingEventID)
    }

    func test_handle_unknownPath_isIgnored() {
        let router = UniversalLinkRouter()
        let unknown = URL(string: "https://buzz.app/admin/\(UUID().uuidString)")!
        router.handle(unknown)
        XCTAssertNil(router.pendingEventID)
        XCTAssertNil(router.pendingOrgHandle)
        XCTAssertNil(router.pendingProfileHandle)
    }

    func test_handle_eventURL_invalidUUID_isIgnored() {
        let router = UniversalLinkRouter()
        let bad = URL(string: "https://buzz.app/e/not-a-uuid")!
        router.handle(bad)
        XCTAssertNil(router.pendingEventID)
    }
}

/// Independent tests for `BuzzLink` — the URL builder + validator. Critical because
/// a regression in the host or path scheme breaks every shared link in the wild.
final class BuzzLinkTests: XCTestCase {

    func test_event_URL_usesHttpsAndExpectedPath() {
        let id = UUID()
        let url = BuzzLink.event(id)
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "buzz.app")
        XCTAssertEqual(url.path, "/e/\(id.uuidString.lowercased())")
    }

    func test_organization_URL_percentEncodesHandle() {
        let url = BuzzLink.organization(handle: "founders club")
        // Should not crash and should not contain a raw space.
        XCTAssertFalse(url.absoluteString.contains(" "))
    }

    func test_profile_URL_stripsAllLeadingAtSigns() {
        // VULN #84 — multiple leading @s, not just one.
        let url = BuzzLink.profile(handle: "@@@alex")
        XCTAssertEqual(url.path, "/u/alex")
    }

    func test_validate_eventURL_returnsEventKind() {
        let id = UUID()
        guard case .event(let parsed) = BuzzLink.validate(BuzzLink.event(id)) else {
            return XCTFail("Expected .event kind")
        }
        XCTAssertEqual(parsed, id)
    }

    func test_validate_round_tripsOrgURL() {
        guard case .organization(let h) = BuzzLink.validate(BuzzLink.organization(handle: "alpha")) else {
            return XCTFail("Expected .organization kind")
        }
        XCTAssertEqual(h, "alpha")
    }

    func test_validate_rejectsLookalikeHost() {
        let phish = URL(string: "https://buzz.app.evil.example/e/\(UUID().uuidString)")!
        XCTAssertNil(BuzzLink.validate(phish))
    }

    func test_validate_rejectsHTTP() {
        let insecure = URL(string: "http://buzz.app/e/\(UUID().uuidString)")!
        XCTAssertNil(BuzzLink.validate(insecure))
    }

    func test_validate_rejectsExtraPathComponents() {
        let weird = URL(string: "https://buzz.app/e/\(UUID().uuidString)/extra")!
        XCTAssertNil(BuzzLink.validate(weird))
    }

    func test_validate_rejectsTopLevelOnly() {
        let bare = URL(string: "https://buzz.app/")!
        XCTAssertNil(BuzzLink.validate(bare))
    }
}
