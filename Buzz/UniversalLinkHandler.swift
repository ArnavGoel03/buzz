import SwiftUI

/// Routes incoming `buzz.app/...` universal links into the right destination. Works for both
/// AirDrop'd URLs and App Clip handoffs. Apply to the root view via `.onOpenURL`.
@MainActor
final class UniversalLinkRouter: ObservableObject {
    @Published var pendingEventID: UUID?
    @Published var pendingOrgHandle: String?
    @Published var pendingProfileHandle: String?

    func handle(_ url: URL) {
        guard let kind = BuzzLink.validate(url) else { return }
        switch kind {
        case .event(let id):       pendingEventID = id
        case .organization(let h): pendingOrgHandle = h
        case .profile(let h):      pendingProfileHandle = h
        }
    }

    // VULN #58 patch: callers must explicitly consume pending values. Without this, a view
    // re-render could re-trigger navigation in a loop.
    func consumeEvent() -> UUID?         { defer { pendingEventID = nil }; return pendingEventID }
    func consumeOrganization() -> String? { defer { pendingOrgHandle = nil }; return pendingOrgHandle }
    func consumeProfile() -> String?      { defer { pendingProfileHandle = nil }; return pendingProfileHandle }
}

extension View {
    /// Attach to the root view to convert incoming `buzz.app/...` URLs into router state.
    func handleBuzzLinks(_ router: UniversalLinkRouter) -> some View {
        self.onOpenURL { url in router.handle(url) }
    }
}
