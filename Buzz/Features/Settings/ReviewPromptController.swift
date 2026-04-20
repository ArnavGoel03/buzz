import SwiftUI
import StoreKit
#if canImport(UIKit)
import UIKit
#endif

/// Apple's in-app review prompt (3 per year hard limit). Best practice: trigger after
/// a positive moment (RSVP'd 3+ events, attended 1, streak ≥ 2 weeks). Never on first
/// launch, never after an error. Fires via a single @AppStorage counter.
@MainActor
enum ReviewPromptController {
    private static let key = "buzz.review.positiveMoments"

    /// Call after any positive moment (successful RSVP, badge accepted, check-in, etc.).
    /// We throttle internally; Apple throttles further.
    static func recordPositiveMoment() {
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: key) + 1
        defaults.set(count, forKey: key)
        // Ask at the 5th positive moment — past the "accidental tap" noise, before delight fades.
        if count == 5 {
            requestReviewIfPossible()
        }
    }

    private static func requestReviewIfPossible() {
        #if os(iOS)
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else { return }
        AppStore.requestReview(in: scene)
        #endif
        // On macOS the Mac App Store app itself handles review prompts — no-op here.
    }
}
