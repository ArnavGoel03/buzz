import XCTest
@testable import Buzz

final class MembershipRoleTests: XCTestCase {
    func test_prestigeTier_includesFounderPresidentCaptain() {
        XCTAssertEqual(MembershipRole.founder.tier, .prestige)
        XCTAssertEqual(MembershipRole.president.tier, .prestige)
        XCTAssertEqual(MembershipRole.captain.tier, .prestige)
    }

    func test_officerTier_includesOfficerRoles() {
        XCTAssertEqual(MembershipRole.vicePresident.tier, .officer)
        XCTAssertEqual(MembershipRole.treasurer.tier, .officer)
        XCTAssertEqual(MembershipRole.secretary.tier, .officer)
        XCTAssertEqual(MembershipRole.officer.tier, .officer)
        XCTAssertEqual(MembershipRole.lead.tier, .officer)
    }

    func test_memberTier_includesMemberAndAlumni() {
        XCTAssertEqual(MembershipRole.member.tier, .member)
        XCTAssertEqual(MembershipRole.alumni.tier, .member)
    }

    func test_everyRoleHasDisplayNameAndIcon() {
        for role in MembershipRole.allCases {
            XCTAssertFalse(role.displayName.isEmpty, "\(role) missing displayName")
            XCTAssertFalse(role.icon.isEmpty, "\(role) missing icon")
        }
    }
}
