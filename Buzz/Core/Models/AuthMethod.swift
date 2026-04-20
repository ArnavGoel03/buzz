import Foundation

/// Identity providers a user can link to their profile. Multiple methods can be attached
/// to a single profile so users aren't locked into one ecosystem — switch from iPhone to
/// Samsung and sign in with Google (or email OTP) to reach the same account.
///
/// Recovery: every verified `.edu`/institutional email from the user's affiliations is
/// automatically a fallback sign-in method via OTP, so losing all OAuth providers still
/// leaves a path back in.
enum AuthMethod: String, Codable, CaseIterable, Hashable, Sendable {
    case apple                          // Sign in with Apple — required by App Store; great on iOS
    case google                         // Google Sign-In — durable across iOS/Android
    case emailOTP                       // Magic link or 6-digit code to email
    case phoneOTP                       // SMS code (deferred — needs SMS budget + abuse prevention)
}

/// Server-side row linking one identity provider account to a profile.
struct AuthIdentity: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var profileID: UUID
    var method: AuthMethod
    var providerSubject: String         // e.g. Apple user identifier, Google sub claim, email address
    var displayLabel: String?           // optional UI hint, e.g. "yashgoel@gmail.com"
    var linkedAt: Date
    var lastUsedAt: Date?
}
