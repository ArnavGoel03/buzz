import XCTest
@testable import Buzz

@MainActor
final class AuthSessionTests: XCTestCase {

    // MARK: state transitions

    func test_defaultsToGuest() {
        let session = AuthSession()
        if case .guest = session.state {} else {
            XCTFail("Expected initial state to be .guest, got \(session.state)")
        }
        XCTAssertFalse(session.isAuthenticated)
        XCTAssertNil(session.currentProfileID)
    }

    func test_continueWithApple_movesToOnboarding() async {
        let session = AuthSession()
        await session.continueWithApple()
        if case .onboarding = session.state {} else {
            XCTFail("Expected .onboarding after Apple sign-in, got \(session.state)")
        }
        // Authenticated must still be false — onboarding hasn't completed.
        XCTAssertFalse(session.isAuthenticated)
        XCTAssertNil(session.currentProfileID)
    }

    func test_continueWithGoogle_movesToOnboarding() async {
        let session = AuthSession()
        await session.continueWithGoogle()
        if case .onboarding = session.state {} else {
            XCTFail("Expected .onboarding after Google sign-in, got \(session.state)")
        }
    }

    func test_continueWithEmail_movesToOnboarding() async {
        let session = AuthSession()
        await session.continueWithEmail("test@buzz.app")
        if case .onboarding = session.state {} else {
            XCTFail("Expected .onboarding after email sign-in, got \(session.state)")
        }
    }

    func test_completeOnboarding_movesToAuthenticatedAndExposesID() {
        let session = AuthSession()
        let id = UUID()
        session.completeOnboarding(profileID: id)
        XCTAssertTrue(session.isAuthenticated)
        XCTAssertEqual(session.currentProfileID, id)
    }

    func test_restoreSession_authenticatesDirectly() {
        let session = AuthSession()
        let id = UUID()
        session.restoreSession(profileID: id)
        XCTAssertTrue(session.isAuthenticated)
        XCTAssertEqual(session.currentProfileID, id)
    }

    // MARK: VULN #57 — sign out must invoke purge AND clear identity

    func test_signOut_returnsToGuestAndClearsProfileID() {
        let session = AuthSession()
        session.completeOnboarding(profileID: UUID())
        XCTAssertTrue(session.isAuthenticated)

        session.signOut()
        if case .guest = session.state {} else {
            XCTFail("Expected .guest after signOut, got \(session.state)")
        }
        XCTAssertFalse(session.isAuthenticated)
        XCTAssertNil(session.currentProfileID, "currentProfileID must clear on signOut — leaving the previous user's id exposed is VULN #57")
    }

    func test_signOut_invokesPurgeClosure() async throws {
        let session = AuthSession()
        session.completeOnboarding(profileID: UUID())

        let purgeCalled = expectation(description: "purge closure executed")
        session.signOut(purge: {
            purgeCalled.fulfill()
        })

        await fulfillment(of: [purgeCalled], timeout: 1.0)
    }

    // MARK: identity-change observability — RootView relies on currentProfileID changing

    func test_currentProfileID_changesAcrossAccountSwitch() {
        let session = AuthSession()
        let alice = UUID()
        let bob = UUID()

        session.completeOnboarding(profileID: alice)
        XCTAssertEqual(session.currentProfileID, alice)

        session.signOut()
        XCTAssertNil(session.currentProfileID)

        session.completeOnboarding(profileID: bob)
        XCTAssertEqual(session.currentProfileID, bob)
        XCTAssertNotEqual(session.currentProfileID, alice, "Account switch must surface a new profileID — VULN #82 trigger")
    }
}
