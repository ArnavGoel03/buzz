import XCTest
@testable import Buzz

/// Server contract tests. RSVPStatus, EventVisibility, and other persisted enum
/// rawValues map directly to Postgres enum values in Supabase. Renaming a case
/// silently breaks deserialisation across every device on the previous build —
/// pin the wire format here so a code rename forces a deliberate migration.
final class ModelEncodingTests: XCTestCase {

    // MARK: RSVPStatus — wire format

    func test_rsvpStatus_rawValuesMatchServerContract() {
        XCTAssertEqual(RSVPStatus.notGoing.rawValue, "notGoing")
        XCTAssertEqual(RSVPStatus.interested.rawValue, "interested")
        XCTAssertEqual(RSVPStatus.going.rawValue, "going")
    }

    func test_rsvpStatus_decodesEveryCase() throws {
        let cases: [(String, RSVPStatus)] = [
            ("notGoing", .notGoing),
            ("interested", .interested),
            ("going", .going)
        ]
        for (raw, expected) in cases {
            let json = "\"\(raw)\"".data(using: .utf8)!
            let decoded = try JSONDecoder().decode(RSVPStatus.self, from: json)
            XCTAssertEqual(decoded, expected)
        }
    }

    func test_rsvpStatus_rejectsUnknownValue() {
        let json = "\"maybe\"".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(RSVPStatus.self, from: json))
    }

    // MARK: EventVisibility — wire format + UI metadata

    func test_eventVisibility_rawValuesMatchServerContract() {
        XCTAssertEqual(EventVisibility.publicEvent.rawValue, "publicEvent")
        XCTAssertEqual(EventVisibility.campusOnly.rawValue, "campusOnly")
        XCTAssertEqual(EventVisibility.memberOnly.rawValue, "memberOnly")
        XCTAssertEqual(EventVisibility.officersOnly.rawValue, "officersOnly")
        XCTAssertEqual(EventVisibility.inviteOnly.rawValue, "inviteOnly")
    }

    func test_eventVisibility_everyCaseHasDisplayNameAndIcon() {
        for v in EventVisibility.allCases {
            XCTAssertFalse(v.displayName.isEmpty, "\(v) missing displayName")
            XCTAssertFalse(v.icon.isEmpty, "\(v) missing icon")
        }
    }

    // MARK: Event — round-trip Codable

    func test_event_roundTripsThroughJSON() throws {
        let original = Event(
            id: UUID(),
            title: "Sigma Phi Rush — Day 3",
            summary: "Pizza, pong, paddle.",
            category: .party,
            startsAt: Date(timeIntervalSinceReferenceDate: 700_000_000),
            endsAt: Date(timeIntervalSinceReferenceDate: 700_007_200),
            location: EventLocation(
                name: "Greek Row",
                address: "123 Library Walk",
                latitude: 32.8812,
                longitude: -117.2374
            ),
            hostName: "Sigma Phi",
            organizationID: UUID(),
            subCampus: "warren",
            timezone: "America/Los_Angeles",
            visibility: .campusOnly,
            hideAttendees: true,
            capacity: 200,
            rsvpCount: 47,
            imageURL: URL(string: "https://example.com/x.jpg"),
            tags: ["greek", "rush"],
            isOfficial: false
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(original)
        let round = try JSONDecoder().decode(Event.self, from: data)

        XCTAssertEqual(original, round)
    }

    // MARK: Event invariants

    func test_event_isLiveAndStartsWithinHour_areMutuallyExclusive() {
        let starting = Event(
            id: UUID(), title: "S", summary: "",
            category: .party,
            startsAt: Date().addingTimeInterval(600),
            endsAt: Date().addingTimeInterval(4200),
            location: EventLocation(name: "X", address: nil, latitude: 0, longitude: 0),
            hostName: "H", organizationID: nil, subCampus: nil,
            capacity: nil, rsvpCount: 0, imageURL: nil, tags: [], isOfficial: false
        )
        XCTAssertFalse(starting.isLive)
        XCTAssertTrue(starting.startsWithinHour)

        let live = Event(
            id: UUID(), title: "L", summary: "",
            category: .party,
            startsAt: Date().addingTimeInterval(-300),
            endsAt: Date().addingTimeInterval(3300),
            location: EventLocation(name: "X", address: nil, latitude: 0, longitude: 0),
            hostName: "H", organizationID: nil, subCampus: nil,
            capacity: nil, rsvpCount: 0, imageURL: nil, tags: [], isOfficial: false
        )
        XCTAssertTrue(live.isLive)
        XCTAssertFalse(live.startsWithinHour, "Already live ⇒ startsAt is in the past ⇒ startsWithinHour false")
    }
}
