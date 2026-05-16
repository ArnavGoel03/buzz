import SwiftUI
import StoreKit
#if canImport(UIKit)
import UIKit
#endif

/// Apple's in-app review prompt (3 per year hard limit). Best practice: trigger after
/// a positive moment (RSVP'd 3+ events, attended 1, streak ≥ 2 weeks). Never on first
/// launch, never after an error. Fires via a single UserDefaults counter.
@MainActor
enum ReviewPromptController {
    static let key = "buzz.review.positiveMoments"
    static let triggerAt = 5

    /// Call after any positive moment (successful RSVP, badge accepted, check-in, etc.).
    /// We throttle internally; Apple throttles further.
    /// - Returns: `true` if this call hit the trigger threshold and a review prompt was
    ///   requested. Lets tests verify the throttle without mocking StoreKit.
    @discardableResult
    static func recordPositiveMoment(defaults: UserDefaults = .standard) -> Bool {
        let count = defaults.integer(forKey: key) + 1
        defaults.set(count, forKey: key)
        // Ask at the Nth positive moment — past the "accidental tap" noise, before delight fades.
        if count == triggerAt {
            requestReviewIfPossible()
            return true
        }
        return false
    }

    private static func requestReviewIfPossible() {
        #if os(iOS)
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else { return }
        AppStore.requestReview(in: scene)
        #elseif os(macOS)
        AppStore.requestReview()
        #endif
    }
}
