import SwiftUI

/// Officer-only entry point. Lives on the org admin row; one tap → full-screen booth display.
struct TablingLaunchButton: View {
    let organization: Organization
    @State private var showing = false

    var body: some View {
        Button {
            Haptics.tap()
            showing = true
        } label: {
            Label("Tabling mode", systemImage: "rectangle.portrait.and.arrow.right.fill")
                .font(BuzzFont.captionBold)
                .foregroundStyle(.black)
                .padding(.horizontal, BuzzSpacing.md)
                .padding(.vertical, BuzzSpacing.xs)
                .background(Capsule().fill(organization.accent))
        }
        .buttonStyle(.plain)
        .fullCover(isPresented: $showing) {
            TablingModeView(organization: organization)
        }
    }
}
