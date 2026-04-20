import Foundation

/// Retries an async throwing operation with exponential backoff + jitter. Use at repository
/// boundaries, not inside view models (views stay simple and call the repo once).
enum Retry {
    static func run<T: Sendable>(
        maxAttempts: Int = 3,
        initialDelay: TimeInterval = 0.35,
        _ operation: @Sendable () async throws -> T
    ) async throws -> T {
        var attempt = 0
        var delay = initialDelay
        while true {
            do {
                return try await operation()
            } catch {
                attempt += 1
                if attempt >= maxAttempts { throw error }
                let jitter = Double.random(in: 0...(delay * 0.4))
                try? await Task.sleep(for: .seconds(delay + jitter))
                delay *= 2
            }
        }
    }
}
