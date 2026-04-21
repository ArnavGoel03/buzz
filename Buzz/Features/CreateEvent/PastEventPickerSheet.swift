import SwiftUI

/// Pick one past event to re-invite its RSVPs. Sorted by most recent so the obvious
/// choice ("the last event we did") is right at the top.
struct PastEventPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let events: [Event]
    let onPick: (Event) -> Void

    var body: some View {
        NavigationStack {
            List {
                if events.isEmpty {
                    Text("No past events yet.")
                        .font(BuzzFont.body)
                        .foregroundStyle(BuzzColor.textTertiary)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(events) { event in
                        Button {
                            Haptics.tap(); onPick(event); dismiss()
                        } label: {
                            HStack(spacing: BuzzSpacing.md) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title).font(BuzzFont.bodyEmphasis)
                                        .foregroundStyle(BuzzColor.textPrimary)
                                    Text("\(event.rsvpCount) RSVPs · \(event.startsAt.formatted(date: .abbreviated, time: .omitted))")
                                        .font(BuzzFont.caption)
                                        .foregroundStyle(BuzzColor.textTertiary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(BuzzColor.textTertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(BuzzColor.surface)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(BuzzColor.background)
            .navigationTitle("Re-invite from")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}
