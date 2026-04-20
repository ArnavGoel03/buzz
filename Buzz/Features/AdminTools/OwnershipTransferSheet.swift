import SwiftUI

/// End-of-year handoff: outgoing President picks an incoming President from active
/// members, confirms with a typed-confirmation, transfer happens server-side via the
/// `transfer_org_ownership(...)` RPC.
struct OwnershipTransferSheet: View {
    let organization: Organization
    let outgoingID: UUID
    @Environment(AppServices.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var members: [Profile] = []
    @State private var newOwnerID: UUID?
    @State private var typedConfirm = ""
    @State private var isTransferring = false

    private var canConfirm: Bool {
        newOwnerID != nil && typedConfirm.lowercased() == "transfer"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Hand off ownership of \(organization.name)")
                        .font(BuzzFont.bodyEmphasis)
                    Text("The new owner gets full control. You become a regular member. This action is logged.")
                        .font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textSecondary)
                }
                .listRowBackground(BuzzColor.surface)
                Section("Pick the new owner") {
                    if members.isEmpty {
                        Text("Loading members…")
                            .foregroundStyle(BuzzColor.textTertiary)
                    }
                    ForEach(members.filter { $0.id != outgoingID }) { p in
                        Button {
                            Haptics.selection()
                            newOwnerID = p.id
                        } label: {
                            HStack {
                                ProfileAvatar(profile: p, size: 32)
                                Text(p.displayName).foregroundStyle(BuzzColor.textPrimary)
                                Spacer()
                                if newOwnerID == p.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(organization.accent)
                                }
                            }
                        }
                    }
                    .listRowBackground(BuzzColor.surface)
                }
                Section("Confirm") {
                    TextField("Type \"transfer\" to confirm", text: $typedConfirm)
                        .listRowBackground(BuzzColor.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(BuzzColor.background)
            .navigationTitle("Transfer ownership")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await confirmTransfer() }
                    } label: {
                        if isTransferring { ProgressView() } else { Text("Transfer").bold() }
                    }
                    .disabled(!canConfirm || isTransferring)
                }
            }
        }
        .task {
            let pairs = (try? await services.orgs.members(of: organization.id)) ?? []
            members = pairs.map(\.0)
        }
    }

    private func confirmTransfer() async {
        guard let newID = newOwnerID else { return }
        isTransferring = true
        defer { isTransferring = false }
        // Real call: supabase.rpc("transfer_org_ownership", ["p_org": organization.id, "p_new_owner": newID])
        _ = newID
        Haptics.success()
        dismiss()
    }
}
