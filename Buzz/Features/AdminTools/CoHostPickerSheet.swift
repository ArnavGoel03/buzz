import SwiftUI

/// Officer selects other orgs to co-host an event with. The selected orgs' officers will
/// also be able to edit; the event appears in each co-host's feed.
struct CoHostPickerSheet: View {
    @Binding var selected: Set<UUID>
    let currentOrgID: UUID
    @Environment(AppServices.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var available: [Organization] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: BuzzSpacing.md) {
                ClubSearchBar(query: $query)
                    .padding(.horizontal, BuzzSpacing.lg)
                List(filtered) { org in
                    Button {
                        Haptics.selection()
                        if selected.contains(org.id) { selected.remove(org.id) }
                        else { selected.insert(org.id) }
                    } label: {
                        HStack(spacing: BuzzSpacing.md) {
                            BadgeLogoMark(organization: org, size: 36)
                            VStack(alignment: .leading) {
                                Text(org.name).font(BuzzFont.bodyEmphasis)
                                Text(org.tagline).font(BuzzFont.caption)
                                    .foregroundStyle(BuzzColor.textSecondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            if selected.contains(org.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(org.accent)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(BuzzColor.surface)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(BuzzColor.background)
            .navigationTitle("Co-hosts")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.bold()
                }
            }
        }
        .task {
            // Load orgs at the same campus the current org is at.
            if let campus = (try? await services.orgs.organization(id: currentOrgID))?.campus {
                available = ((try? await services.orgs.organizations(campus: campus)) ?? [])
                    .filter { $0.id != currentOrgID }
            }
        }
    }

    private var filtered: [Organization] {
        guard !query.isEmpty else { return available }
        let q = query.lowercased()
        return available.filter {
            $0.name.lowercased().contains(q) || $0.handle.lowercased().contains(q)
        }
    }
}
