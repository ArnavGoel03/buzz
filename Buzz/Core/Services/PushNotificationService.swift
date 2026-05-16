import Foundation
#if canImport(UIKit)
import UIKit
import UserNotifications
#endif
import Observation
import Supabase

/// Registers the device with APNs, persists the device token to Supabase, and handles
/// the foreground/background presentation of incoming pushes. Silent no-op on macOS
/// native where remote push registration works differently.
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
            if granted { await UIApplication.shared.registerForRemoteNotifications() }
        } catch { isAuthorized = false }
    }

    /// Call from `UIApplicationDelegate.didRegisterForRemoteNotificationsWithDeviceToken`.
    func registerDeviceToken(_ data: Data) async {
        let tokenString = data.map { String(format: "%02x", $0) }.joined()
        self.token = tokenString
        await postToken(tokenString, platform: "ios_apns")
    }
    #else
    func requestAuthorization() async { isAuthorized = false }
    func registerDeviceToken(_ data: Data) async {}
    #endif

    /// Server derives `profile_id` from the session JWT — never trust a client-supplied id.
    /// Web push subscription path removed (PWA shell ripped); native APNs + FCM are the
    /// only registered platforms now.
    private func postToken(_ token: String, platform: String) async {
        guard let url = URL(string: "https://buzz.app/api/push/token") else { return }
        // Pull the access token from the live Supabase session; without it the route
        // returns 401 and the device is never registered.
        let session = try? await BuzzSupabase.shared.auth.session
        guard let jwt = session?.accessToken else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        req.httpBody = try? JSONSerialization.data(withJSONObject: [
            "platform": platform, "token": token,
        ])
        _ = try? await URLSession.shared.data(for: req)
    }
}
