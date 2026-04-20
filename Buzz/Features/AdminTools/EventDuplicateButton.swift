import SwiftUI

/// One-tap duplicate. Officer taps "Duplicate," gets a CreateEventSheet pre-filled with
/// the previous event's title, summary, location, capacity, etc. — only date/time blank.
/// The duplicated event records `template_of_event_id` in the schema for analytics.
struct EventDuplicateButton: View {
    let source: Event
    let hostProfile: Profile
    let hostOrganization: Organization?
    @State private var showingSheet = false

    var body: some View {
        Button {
            Haptics.tap()
            showingSheet = true
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc.fill")
                .font(BuzzFont.captionBold)
                .foregroundStyle(.black)
                .padding(.horizontal, BuzzSpacing.md)
                .padding(.vertical, BuzzSpacing.xs)
                .background(Capsule().fill(BuzzColor.accent))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingSheet) {
            CreateEventSheet(
                hostProfile: hostProfile,
                hostOrganization: hostOrganization,
                template: source
            )
            .iosDragIndicator()
            .presentationBackground(.ultraThinMaterial)
        }
    }
}
