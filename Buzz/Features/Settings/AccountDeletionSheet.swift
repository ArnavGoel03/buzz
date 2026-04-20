import SwiftUI

/// In-app account deletion per App Store guideline 5.1.1(v). Must be reachable in the
/// app without a phone call or webmail, must delete — not just deactivate — within 30 days,
/// and must be irrevocable. Calls `delete_my_account()` SECURITY DEFINER RPC.
struct AccountDeletionSheet: View {
    @Environment(AuthSession.self) private var auth
    @Environment(\.dismiss) private var dismiss
    @State private var confirmation = ""
    @State private var isDeleting = false

    var canDelete: Bool {
        confirmation.lowercased() == "delete" && !isDeleting
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BuzzSpacing.lg) {
                    Label("This is permanent", systemImage: "exclamationmark.triangle.fill")
                        .font(BuzzFont.headline)
                        .foregroundStyle(BuzzColor.live)

                    VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
                        Text("Deleting your account removes:")
                            .font(BuzzFont.bodyEmphasis)
                        bullet("Your profile, affiliations, and verification history")
                        bullet("All your RSVPs, check-ins, streaks, badges")
                        bullet("Your DMs and group chat memberships")
                        bullet("Photos you uploaded from events")
                        bullet("Textbook listings you posted")
                        Text("Events you created stay (anonymized as 'Deleted user') so other attendees aren't affected.")
                            .font(BuzzFont.caption)
                            .foregroundStyle(BuzzColor.textSecondary)
                            .padding(.top, BuzzSpacing.sm)
                    }

                    Text("Type DELETE to confirm:")
                        .font(BuzzFont.captionBold)
                        .foregroundStyle(BuzzColor.textSecondary)
                    TextField("DELETE", text: $confirmation)
                        .iosUppercaseInput()
                        .padding(BuzzSpacing.md)
                        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))

                    Button {
                        Haptics.heavy()
                        Task { await runDelete() }
                    } label: {
                        HStack {
                            if isDeleting { ProgressView().tint(.white) }
                            Text("Permanently delete my account")
                                .font(BuzzFont.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, BuzzSpacing.md)
                        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.live))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canDelete)
                    .opacity(canDelete ? 1 : 0.4)

                    Text("Your data is deleted within 30 days per GDPR / CCPA. Audit-log entries are anonymized but retained for legal compliance.")
                        .font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textTertiary)
                }
                .padding(BuzzSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Delete account")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: BuzzSpacing.sm) {
            Text("•").foregroundStyle(BuzzColor.textTertiary)
            Text(text).font(BuzzFont.body).foregroundStyle(BuzzColor.textPrimary)
        }
    }

    private func runDelete() async {
        isDeleting = true
        defer { isDeleting = false }
        // Production: supabase.rpc("delete_my_account")
        try? await Task.sleep(for: .seconds(1))
        auth.signOut()
        dismiss()
    }
}
