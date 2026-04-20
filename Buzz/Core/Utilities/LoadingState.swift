import Foundation

/// Uniform load state used by every view model. Lets views render idle/loading/error states
/// consistently instead of each feature reinventing its own flags.
enum LoadingState<Value>: Sendable where Value: Sendable {
    case idle
    case loading
    case loaded(Value)
    case failed(AppError)

    var value: Value? {
        if case let .loaded(v) = self { return v }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var error: AppError? {
        if case let .failed(err) = self { return err }
        return nil
    }
}

/// Narrowed error surface. Keeps SwiftUI views out of the business of inspecting URLError / DecodingError.
enum AppError: Error, Sendable, Hashable {
    case offline                // no connectivity
    case timedOut               // server took too long
    case backendDown            // 5xx or unreachable
    case notFound
    case unauthorized
    case rateLimited(retryAfter: Int?)
    case decoding
    case unknown(String)

    var userMessage: String {
        switch self {
        case .offline: "You're offline. Showing saved events."
        case .timedOut: "The network is slow. Try again."
        case .backendDown: "Buzz is having a moment. We're on it."
        case .notFound: "Not found."
        case .unauthorized: "Please sign in again."
        case .rateLimited: "Too many requests. Try again in a bit."
        case .decoding: "Something's off with the data."
        case .unknown(let msg): msg
        }
    }

    var isRetryable: Bool {
        switch self {
        case .offline, .timedOut, .backendDown, .rateLimited: true
        case .notFound, .unauthorized, .decoding, .unknown: false
        }
    }
}
