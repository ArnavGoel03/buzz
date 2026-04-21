import SwiftUI

/// The "Custom" source chip opens this — one input box, auto-detects type (email /
/// phone / name / handle), multi-select results with disambiguation, and a "Recent" +
/// "In your club" row above the search for one-tap add.
struct PeopleSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppServices.self) private var services

    let orgID: UUID?
    /// Called with the chosen people when the user taps "Add N".
    let onAdd: (Set<InvitePerson>) -> Void

    @State private var query = ""
    @State private var results: [InvitePerson] = []
    @State private var recent: [InvitePerson] = []
    @State private var inClub: [InvitePerson] = []
    @State private var selected: Set<InvitePerson> = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField
                if query.isEmpty {
                    suggestions
                } else {
                    resultsList
                }
            }
            .background(BuzzColor.background)
            .navigationTitle("Invite people")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button { onAdd(selected); dismiss() } label: {
                        Text(selected.isEmpty ? "Add" : "Add \(selected.count)").bold()
                    }
                    .disabled(selected.isEmpty)
                }
            }
        }
        .task { await loadSuggestions() }
        .task(id: query) { await search() }
    }

    private var searchField: some View {
        HStack(spacing: BuzzSpacing.sm) {
            Image(systemName: inputKind.icon)
                .foregroundStyle(BuzzColor.textTertiary)
            TextField("Email, phone, name, or @handle", text: $query)
                .iosLowercaseInput()
                .submitLabel(.search)
            if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(BuzzColor.textTertiary)
                }
            }
        }
        .padding(BuzzSpacing.md)
        .background(BuzzColor.surface)
        .overlay(alignment: .bottom) {
            Divider().overlay(BuzzColor.border)
        }
    }

    @ViewBuilder
    private var suggestions: some View {
        List {
            if !recent.isEmpty {
                Section("Recent") {
                    ForEach(recent) { person in
                        PersonRow(person: person, isSelected: selected.contains(person))
                            .onTapGesture { toggle(person) }
                            .listRowBackground(BuzzColor.surface)
                    }
                }
            }
            if !inClub.isEmpty {
                Section("In your club") {
                    ForEach(inClub) { person in
                        PersonRow(person: person, isSelected: selected.contains(person))
                            .onTapGesture { toggle(person) }
                            .listRowBackground(BuzzColor.surface)
                    }
                }
            }
            if recent.isEmpty && inClub.isEmpty {
                Text("Start typing an email, phone, or name.")
                    .font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textTertiary)
                    .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private var resultsList: some View {
        List {
            if isSearching {
                HStack { Spacer(); ProgressView(); Spacer() }
                    .listRowBackground(Color.clear)
            } else if results.isEmpty {
                noResults
            } else {
                ForEach(results) { person in
                    PersonRow(person: person, isSelected: selected.contains(person))
                        .onTapGesture { toggle(person) }
                        .listRowBackground(BuzzColor.surface)
                }
            }
        }
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private var noResults: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            Text("No one on Buzz matches \"\(query)\".")
                .font(BuzzFont.body)
            if inputKind == .email {
                Text("Send the invite anyway? We'll email them so they can join.")
                    .font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textSecondary)
                Button {
                    addEmailInvite()
                } label: {
                    Label("Invite \(query) by email", systemImage: "paperplane.fill")
                        .font(BuzzFont.bodyEmphasis)
                }
                .buttonStyle(.borderedProminent)
                .tint(BuzzColor.accent)
            }
        }
        .listRowBackground(Color.clear)
    }

    // MARK: - Input detection

    private enum InputKind { case email, phone, name
        var icon: String { switch self { case .email: "envelope"; case .phone: "phone"; case .name: "magnifyingglass" } }
    }

    private var inputKind: InputKind {
        if query.contains("@") { return .email }
        if query.allSatisfy({ $0.isNumber || "()+-. ".contains($0) }), query.count >= 7 { return .phone }
        return .name
    }

    // MARK: - Actions

    private func toggle(_ p: InvitePerson) {
        if selected.contains(p) { selected.remove(p) } else { selected.insert(p) }
        Haptics.selection()
    }

    private func addEmailInvite() {
        let synthetic = InvitePerson(
            id: UUID(), displayName: query, handle: "", email: query,
            phone: nil, campus: nil, graduatingYear: nil, avatarURL: nil
        )
        selected.insert(synthetic)
    }

    private func loadSuggestions() async {
        recent = (try? await services.invites.recentlyInvited()) ?? []
        if let orgID { inClub = (try? await services.invites.members(of: orgID)) ?? [] }
    }

    private func search() async {
        guard !query.isEmpty else { results = []; return }
        isSearching = true
        defer { isSearching = false }
        // 300ms debounce so we don't hammer the backend on every keystroke.
        try? await Task.sleep(for: .milliseconds(300))
        guard !Task.isCancelled else { return }
        results = (try? await services.invites.search(query: query)) ?? []
    }
}

private struct PersonRow: View {
    let person: InvitePerson
    let isSelected: Bool

    var body: some View {
        HStack(spacing: BuzzSpacing.md) {
            ZStack {
                Circle().fill(BuzzColor.surface2).frame(width: 40, height: 40)
                Text(String(person.displayName.prefix(1)))
                    .font(BuzzFont.bodyEmphasis)
                    .foregroundStyle(BuzzColor.textSecondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(person.displayName).font(BuzzFont.bodyEmphasis)
                HStack(spacing: BuzzSpacing.xs) {
                    Text(person.email).font(BuzzFont.caption).foregroundStyle(BuzzColor.textTertiary)
                    if !person.disambiguator.isEmpty {
                        Text("·").foregroundStyle(BuzzColor.textTertiary)
                        Text(person.disambiguator).font(BuzzFont.caption).foregroundStyle(BuzzColor.textTertiary)
                    }
                }
            }
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? BuzzColor.accent : BuzzColor.textTertiary)
                .font(.system(size: 22))
        }
        .padding(.vertical, BuzzSpacing.xs)
        .contentShape(Rectangle())
    }
}
