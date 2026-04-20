import Foundation
#if canImport(UIKit)
import UIKit
import UserNotifications
#endif
import Observation

/// Registers the device with APNs, persists the device token to Supabase, and handles
/// the foreground/background presentation of incoming pushes. Silent no-op on macOS
/// native where remote push registration works differently (handled via a companion
/// Mac Push extension in a later pass).
@Observable
@MainActor
final class PushNotificationService: NSObject {
    private(set) var isAuthorized: Bool = false
    private(set) var token: String?

    #if canImport(UIKit)
    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            if granted {
                await UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            isAuthorized = false
        }
    }

    /// Call from your `UIApplicationDelegate.didRegisterForRemoteNotificationsWithDeviceToken`.
    /// Persists the token to Supabase via the `/api/push/token` endpoint.
    func registerDeviceToken(_ data: Data, profileID: UUID) async {
        let tokenString = data.map { String(format: "%02x", $0) }.joined()
        self.token = tokenString
        await postToken(tokenString, platform: "ios_apns", profileID: profileID)
    }
    #else
    func requestAuthorization() async { isAuthorized = false }
    func registerDeviceToken(_ data: Data, profileID: UUID) async {}
    #endif

    /// Used by the PWA path — the browser service worker fetches a VAPID-based push
    /// subscription and hands it back via this method (web build only).
    func registerWebPushSubscription(_ subscription: String, profileID: UUID) async {
        await postToken(subscription, platform: "web_push", profileID: profileID)
    }

    private func postToken(_ token: String, platform: String, profileID: UUID) async {
        guard let url = URL(string: "https://buzz.app/api/push/token") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "profile_id": profileID.uuidString,
            "platform": platform,
            "token": token,
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        _ = try? await URLSession.shared.data(for: req)
    }
}
