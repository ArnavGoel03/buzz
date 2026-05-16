import XCTest
@testable import Buzz

/// Apple allows three review prompts per year, so getting the throttle wrong risks
/// burning a quota on something that isn't even a "delight" moment. Pin the trigger
/// count exactly.
@MainActor
final class ReviewPromptControllerTests: XCTestCase {

    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        // Isolated suite per test — never touch `.standard`.
        let suiteName = "buzz.tests.reviewprompt.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: defaults.dictionaryRepresentation().keys.first ?? "")
        defaults = nil
        super.tearDown()
    }

    func test_doesNotTriggerBeforeThreshold() {
        for i in 1..<ReviewPromptController.triggerAt {
            let triggered = ReviewPromptController.recordPositiveMoment(defaults: defaults)
            XCTAssertFalse(triggered, "Should not trigger at moment \(i)")
        }
        XCTAssertEqual(defaults.integer(forKey: ReviewPromptController.key),
                       ReviewPromptController.triggerAt - 1)
    }

    func test_triggersExactlyOnceAtThreshold() {
        for _ in 1..<ReviewPromptController.triggerAt {
            _ = ReviewPromptController.recordPositiveMoment(defaults: defaults)
        }
        let triggered = ReviewPromptController.recordPositiveMoment(defaults: defaults)
        XCTAssertTrue(triggered, "Trigger must fire on the Nth positive moment")
    }

    func test_doesNotRetriggerAfterThreshold() {
        // Walk past the trigger.
        for _ in 1...(ReviewPromptController.triggerAt + 5) {
            _ = ReviewPromptController.recordPositiveMoment(defaults: defaults)
        }
        // From here, every call should be false (the trigger is `count == triggerAt` only).
        for _ in 1...3 {
            XCTAssertFalse(ReviewPromptController.recordPositiveMoment(defaults: defaults))
        }
    }

    func test_persistsCountAcrossInvocations() {
        _ = ReviewPromptController.recordPositiveMoment(defaults: defaults)
        _ = ReviewPromptController.recordPositiveMoment(defaults: defaults)
        XCTAssertEqual(defaults.integer(forKey: ReviewPromptController.key), 2)
    }
}
