import Foundation
import CoreLocation
import Observation
#if canImport(UIKit)
import UIKit
#endif

@Observable
@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    /// Default = Geisel Library (UCSD). Used until the real fix arrives.
    private(set) var coordinate: CLLocationCoordinate2D = .init(latitude: 32.8812, longitude: -117.2374)
    private(set) var authorization: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 30
        authorization = manager.authorizationStatus
        // VULN #73 patch: pause GPS while the app is backgrounded. iOS / iPadOS use
        // UIApplication lifecycle notifications. macOS doesn't background apps the same
        // way (they just lose focus) and CoreLocation handles laptop sleep itself, so we
        // don't need to subscribe there.
        #if canImport(UIKit) && !os(visionOS)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleBackgrounded),
            name: UIApplication.didEnterBackgroundNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleForegrounded),
            name: UIApplication.willEnterForegroundNotification, object: nil
        )
        #endif
    }

    @objc private func handleBackgrounded() { manager.stopUpdatingLocation() }
    @objc private func handleForegrounded() {
        if Self.isAuthorized(authorization) {
            manager.startUpdatingLocation()
        }
    }

    /// `.authorizedWhenInUse` is iOS-only; on macOS only `.authorizedAlways` exists.
    /// Centralized so the platform gate lives in one place.
    nonisolated static func isAuthorized(_ status: CLAuthorizationStatus) -> Bool {
        #if os(iOS)
        return status == .authorizedWhenInUse || status == .authorizedAlways
        #else
        return status == .authorizedAlways
        #endif
    }

    func requestWhenInUse() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.authorization = status
            if Self.isAuthorized(status) {
                self.manager.startUpdatingLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        let coord = loc.coordinate
        Task { @MainActor in
            self.coordinate = coord
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silent fallback — we keep the default coordinate.
    }
}
