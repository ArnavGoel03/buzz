import SwiftUI

/// Stackable invite sources + running count + people search. Organizer picks one or
/// more source chips (all members / board / past event RSVPs / custom) and the sheet
/// resolves them into a deduped total "invited" list that gets written to
/// event_invites on publish.
struct InviteListBuilderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppServices.self) private var services

    let hostOrg: Organization?
    @Binding var sources: Set<InviteSource>
    @Binding var customPeople: Set<InvitePerson>

    @State private var pastEvents: [Event] = []
    @State private var resolvedCount: Int = 0
    @State private var showingPeopleSearch = false
    @State private var showingPastEventPicker = false
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            List {
                summarySection
                sourcesSection
                if !customPeople.isEmpty { customPeopleSection }
                if !sources.isEmpty { previewSection }
            }
            .scrollContentBackground(.hidden)
            .background(BuzzColor.background)
            .navigationTitle("Who's invited")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.bold()
                }
            }
        }
        .task { await loadContext() }
        .task(id: sources) { await refreshResolvedCount() }
        .sheet(isPresented: $showingPeopleSearch) {
            PeopleSearchSheet(orgID: hostOrg?.id) { picked in
                customPeople.formUnion(picked)
                for p in picked {
                    sources.insert(.customPerson(profileID: p.id, displayName: p.displayName, email: p.email))
                }
            }
        }
        .sheet(isPresented: $showingPastEventPicker) {
            PastEventPickerSheet(events: pastEvents) { e in
                sources.insert(.pastEventRSVPs(eventID: e.id, eventTitle: e.title, rsvpCount: e.rsvpCount))
            }
        }
    }

    private var summarySection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(resolvedCount)").font(BuzzFont.title)
                    Text(resolvedCount == 1 ? "person invited" : "people invited")
                        .font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textSecondary)
                }
                Spacer()
                if isLoading { ProgressView() }
            }
        }
        .listRowBackground(BuzzColor.accentDim)
    }

    private var sourcesSection: some View {
        Section("Add from") {
            if let org = hostOrg {
                SourceButton(
                    icon: "person.3.fill", label: "All members of \(org.name)",
                    subtitle: "\(org.memberCount) people"
                ) {
                    sources.insert(.allMembers(orgID: org.id, memberCount: org.memberCount))
                }
                SourceButton(
                    icon: "star.square.fill", label: "Board only",
                    subtitle: "officers, president, founders"
                ) {
                    Task {
                        let n = (try? await services.invites.boardCount(of: org.id)) ?? 0
                        sources.insert(.boardOnly(orgID: org.id, boardCount: n))
                    }
                }
            }
            SourceButton(
                icon: "calendar.badge.checkmark", label: "Everyone from a past event",
                subtitle: "pick one — re-invite all RSVPs"
            ) {
                showingPastEventPicker = true
            }
            SourceButton(
                icon: "magnifyingglass", label: "Search specific people",
                subtitle: "email, phone, name, or @handle"
            ) {
                showingPeopleSearch = true
            }
        }
        .listRowBackground(BuzzColor.surface)
    }

    private var customPeopleSection: some View {
        Section("Individuals") {
            ForEach(Array(customPeople).sorted(by: { $0.displayName < $1.displayName })) { p in
                HStack {
                    Text(p.displayName).font(BuzzFont.bodyEmphasis)
                    Spacer()
                    Text(p.email).font(BuzzFont.caption).foregroundStyle(BuzzColor.textTertiary)
                    Button {
                        customPeople.remove(p)
                        sources.remove(.customPerson(profileID: p.id, displayName: p.displayName, email: p.email))
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(BuzzColor.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listRowBackground(BuzzColor.surface)
    }

    private var previewSection: some View {
        Section("Sources") {
            ForEach(Array(sources.filter { if case .customPerson = $0 { return false }; return true }), id: \.self) { src in
                HStack {
                    Label(src.label, systemImage: src.icon)
                        .font(BuzzFont.body)
                    Spacer()
                    Button { sources.remove(src) } label: {
                        Image(systemName: "minus.circle.fill").foregroundStyle(BuzzColor.live)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listRowBackground(BuzzColor.surface)
    }

    private func loadContext() async {
        isLoading = true
        defer { isLoading = false }
        guard let org = hostOrg else { return }
        pastEvents = (try? await services.invites.pastEvents(of: org.id)) ?? []
    }

    private func refreshResolvedCount() async {
        resolvedCount = (try? await services.invites.resolveCount(sources: sources)) ?? 0
    }
}

private struct SourceButton: View {
    let icon: String
    let label: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: { Haptics.tap(); action() }) {
            HStack(spacing: BuzzSpacing.md) {
                Image(systemName: icon)
                    .foregroundStyle(BuzzColor.accent)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(BuzzFont.bodyEmphasis).foregroundStyle(BuzzColor.textPrimary)
                    Text(subtitle).font(BuzzFont.caption).foregroundStyle(BuzzColor.textTertiary)
                }
                Spacer()
                Image(systemName: "plus.circle.fill").foregroundStyle(BuzzColor.accent)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
