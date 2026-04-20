import Foundation
import Network
import Observation

/// Observable connectivity + expensive-path flag. Views read `isOnline` to show the offline
/// banner; repos read `isConstrained` to skip image preloads on cellular/low-data.
@Observable
@MainActor
final class NetworkMonitor {
    private(set) var isOnline: Bool = true
    private(set) var isConstrained: Bool = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.buzz.networkmonitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let online = path.status == .satisfied
            let constrained = path.isConstrained || path.isExpensive
            Task { @MainActor in
                self?.isOnline = online
                self?.isConstrained = constrained
            }
        }
        monitor.start(queue: queue)
    }

    deinit { monitor.cancel() }
}
