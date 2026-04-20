import SwiftUI

/// The "..." menu that shows up on every event, org, and profile header. Keeps reporting
/// one tap away without cluttering the UI.
struct ReportMenuButton: View {
    let target: ReportTarget
    @State private var showingReport = false

    var body: some View {
        Menu {
            Button {
                Haptics.tap()
                showingReport = true
            } label: {
                Label("Report", systemImage: "flag.fill")
            }
            ShareLink(item: shareURL, preview: SharePreview("Buzz")) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(BuzzColor.textSecondary)
        }
        .sheet(isPresented: $showingReport) {
            ReportSheet(target: target)
                .presentationDetents([.medium, .large])
                .presentationBackground(.ultraThinMaterial)
        }
    }

    private var shareURL: URL {
        switch target {
        case .event(let id): BuzzLink.event(id)
        case .organization(let id): BuzzLink.organization(handle: id.uuidString)   // stub until handle passed
        case .profile(let id): BuzzLink.profile(handle: id.uuidString)
        }
    }
}
