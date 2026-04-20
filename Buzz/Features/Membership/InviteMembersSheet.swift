import SwiftUI

/// Officer-facing sheet for adding members to their org. Search by name/handle, pick a role,
/// tap "Send invite" — the invitee gets a pending membership and accepts on their end.
struct InviteMembersSheet: View {
    let organization: Organization
    let inviterID: UUID
    @Environment(AppServices.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [Profile] = []
    @State private var selectedRole: MembershipRole = .member
    @State private var sentInvitesTo: Set<UUID> = []

    var body: some View {
        VStack(spacing: BuzzSpacing.md) {
            header
            ClubSearchBar(query: $query)
                .padding(.horizontal, BuzzSpacing.lg)
                .onChange(of: query) { _, _ in Task { await search() } }
            roleRow
            if results.isEmpty {
                LoadingStateView(
                    error: nil,
                    isEmpty: true,
                    emptyTitle: query.isEmpty ? "Search students by name or handle" : "No matches",
                    emptyBody: query.isEmpty
                        ? "Invites send a notification — they accept to display the badge on their profile."
                        : "Try a different name. Students must be on Buzz to be invited.",
                    onRetry: nil
                )
            } else {
                List(results) { profile in
                    inviteRow(profile)
                        .listRowBackground(BuzzColor.surface)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(BuzzColor.background.ignoresSafeArea())
        .presentationCornerRadius(32)
    }

    private var header: some View {
        HStack {
            Text("Invite to \(organization.name)")
                .font(BuzzFont.headline)
            Spacer()
            Button("Done") { dismiss() }
                .font(BuzzFont.captionBold)
                .foregroundStyle(organization.accent)
        }
        .padding(.horizontal, BuzzSpacing.lg)
        .padding(.top, BuzzSpacing.lg)
    }

    private var roleRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BuzzSpacing.sm) {
                ForEach(MembershipRole.allCases.filter { $0 != .alumni }, id: \.self) { role in
                    FilterChip(
                        label: role.displayName,
                        icon: role.icon,
                        tint: organization.accent,
                        isActive: selectedRole == role,
                        action: {
                            Haptics.selection()
                            selectedRole = role
                        }
                    )
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
        }
    }

    private func inviteRow(_ profile: Profile) -> some View {
        HStack(spacing: BuzzSpacing.md) {
            ProfileAvatar(profile: profile, size: 36)
            VStack(alignment: .leading, spacing: 1) {
                Text(profile.displayName).font(BuzzFont.bodyEmphasis)
                Text(profile.handle).font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
            }
            Spacer()
            Button {
                Task { await send(to: profile.id) }
            } label: {
                Text(sentInvitesTo.contains(profile.id) ? "Sent" : "Invite")
                    .font(BuzzFont.captionBold)
                    .foregroundStyle(sentInvitesTo.contains(profile.id) ? BuzzColor.textSecondary : .black)
                    .padding(.horizontal, BuzzSpacing.md)
                    .padding(.vertical, BuzzSpacing.sm)
                    .background(Capsule().fill(
                        sentInvitesTo.contains(profile.id) ? Color.white.opacity(0.08) : organization.accent
                    ))
            }
            .buttonStyle(.plain)
            .disabled(sentInvitesTo.contains(profile.id))
        }
        .padding(.vertical, BuzzSpacing.xs)
    }

    private func search() async {
        guard !query.isEmpty else { results = []; return }
        let campus = organization.campus
        let raw = (try? await services.orgs.searchProfiles(query: query, campus: campus, limit: 25)) ?? []
        // VULN #104 patch: hide self from invite list (server enforces uniqueness too).
        results = raw.filter { $0.id != inviterID }
    }

    private func send(to profileID: UUID) async {
        // VULN #103 patch: optimistic-mark, then roll back on failure so user can retry.
        Haptics.success()
        sentInvitesTo.insert(profileID)
        do {
            try await services.orgs.invite(
                profileID: profileID, to: organization.id,
                role: selectedRole, by: inviterID
            )
        } catch {
            sentInvitesTo.remove(profileID)
            Haptics.warning()
        }
    }
}
