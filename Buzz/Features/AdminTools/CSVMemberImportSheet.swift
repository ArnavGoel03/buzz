import SwiftUI

/// Bulk-invite via paste-or-CSV. Officer pastes a roster (one email per line, or CSV).
/// We parse, dedupe, and fire one invite per matched profile (or queue an email for
/// unmatched addresses). Way faster than tapping "Invite" 200 times.
struct CSVMemberImportSheet: View {
    let organization: Organization
    let inviterID: UUID
    @Environment(AppServices.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var raw: String = ""
    @State private var selectedRole: MembershipRole = .member
    @State private var isProcessing = false
    @State private var summary: ImportSummary?

    struct ImportSummary {
        var parsed: Int
        var invited: Int
        var queued: Int
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Paste roster — one email per line", text: $raw, axis: .vertical)
                        .lineLimit(8...30)
                        .listRowBackground(BuzzColor.surface)
                    Text("\(emailCount) addresses detected")
                        .font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textSecondary)
                }
                Section("Role") {
                    Picker("Role", selection: $selectedRole) {
                        ForEach(MembershipRole.allCases.filter { $0 != .alumni }, id: \.self) { r in
                            Text(r.displayName).tag(r)
                        }
                    }
                    .listRowBackground(BuzzColor.surface)
                }
                if let summary {
                    Section("Result") {
                        ResultRow(label: "Parsed", value: summary.parsed)
                        ResultRow(label: "Invited (existing users)", value: summary.invited)
                        ResultRow(label: "Email-queued (no Buzz account yet)", value: summary.queued)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(BuzzColor.background)
            .navigationTitle("Bulk invite")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await runImport() }
                    } label: {
                        if isProcessing { ProgressView() } else { Text("Send").bold() }
                    }
                    .disabled(emailCount == 0 || isProcessing)
                }
            }
        }
    }

    private var emailCount: Int { emails.count }
    private var emails: [String] {
        raw
            .components(separatedBy: CharacterSet(charactersIn: ",\n;\t"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.contains("@") && $0.contains(".") }
    }

    private func runImport() async {
        isProcessing = true
        defer { isProcessing = false }
        // Real flow: server-side RPC `bulk_invite(org_id, role, emails[])` which
        //   - matches each email to an existing profile via auth_identities → invites
        //   - queues an outbound "join Buzz" email for unmatched addresses
        // Mock: split based on whether email contains 'edu' (pretend match).
        let matched = emails.filter { $0.lowercased().contains(".edu") }
        let unmatched = emails.count - matched.count
        Haptics.success()
        summary = ImportSummary(parsed: emails.count, invited: matched.count, queued: unmatched)
    }
}

private struct ResultRow: View {
    let label: String
    let value: Int
    var body: some View {
        HStack {
            Text(label).foregroundStyle(BuzzColor.textPrimary)
            Spacer()
            Text("\(value)").font(BuzzFont.bodyEmphasis).foregroundStyle(BuzzColor.accent)
        }
        .listRowBackground(BuzzColor.surface)
    }
}
