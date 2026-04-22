import SwiftUI

struct OrganizationView: View {
    @Environment(AppServices.self) private var services
    @Environment(AuthSession.self) private var auth
    let organizationID: UUID
    @State private var viewModel: OrganizationViewModel?
    @State private var showingShareSheet = false
    @State private var showingInviteSheet = false
    @State private var currentUserID: UUID?

    var body: some View {
        ScrollView {
            VStack(spacing: BuzzSpacing.xl) {
                if let org = viewModel?.organization {
                    OrganizationHero(organization: org)
                    VStack(spacing: BuzzSpacing.md) {
                        HStack(spacing: BuzzSpacing.sm) {
                            PaperSavedPill(sheets: PaperImpact.sheetsSaved(
                                rsvps: (viewModel?.events ?? []).reduce(0) { $0 + $1.rsvpCount },
                                orgViews: org.memberCount * 4
                            ))
                            Spacer()
                        }
                        .padding(.horizontal, BuzzSpacing.xs)
                        OrganizationStatsRow(organization: org)
                        OrgExternalLinksRow(organization: org)
                        HStack(spacing: BuzzSpacing.sm) {
                            FollowButton(
                                organization: org,
                                isFollowing: Binding(
                                    get: { viewModel?.isFollowing ?? false },
                                    set: { viewModel?.isFollowing = $0 }
                                )
                            )
                            Button {
                                Haptics.tap()
                                showingShareSheet = true
                            } label: {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(org.accent)
                                    .frame(width: 52, height: 52)
                                    .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
                                    .overlay(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).stroke(BuzzColor.border, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, BuzzSpacing.lg)

                    if !org.description.isEmpty {
                        aboutSection(org)
                    }
                    membersSection(org)
                    eventsSection(org)
                    Spacer(minLength: BuzzSpacing.xxl)
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(
            ZStack {
                MetalGradientBackground(intensity: 0.4)
                BuzzColor.background.opacity(0.72)
            }
            .ignoresSafeArea()
        )
        .iosNavigationInline()
        .task {
            if viewModel == nil {
                viewModel = OrganizationViewModel(
                    organizationID: organizationID,
                    orgs: services.orgs,
                    events: services.events
                )
            }
            let coord = services.location.coordinate
            await viewModel?.load(near: coord.latitude, lng: coord.longitude)
            // VULN #67 patch: only resolve currentUserID when actually signed in.
            // Otherwise canManage() could pass for the cached mock identity in guest mode,
            // showing officer-only buttons (Invite, Tabling Mode) to a stranger.
            if currentUserID == nil, let uid = auth.currentProfileID {
                currentUserID = uid
            }
        }
        // VULN #110 patch: drop cached viewModel + identity on auth change so the next
        // user doesn't see the previous user's "Invite" / "Tabling Mode" buttons.
        .onChange(of: auth.currentProfileID) { _, newValue in
            viewModel = nil
            currentUserID = newValue
        }
        .sheet(isPresented: $showingShareSheet) {
            if let org = viewModel?.organization {
                OrgShareSheet(organization: org)
                    .presentationDetents([.large])
                    .presentationBackground(.ultraThinMaterial)
            }
        }
        .sheet(isPresented: $showingInviteSheet) {
            if let org = viewModel?.organization, let uid = currentUserID {
                InviteMembersSheet(organization: org, inviterID: uid)
                    .presentationDetents([.large])
                    .presentationBackground(.ultraThinMaterial)
            }
        }
    }

    private func aboutSection(_ org: Organization) -> some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            Text("About")
                .font(BuzzFont.headline)
                .foregroundStyle(BuzzColor.textPrimary)
            Text(org.description)
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textSecondary)
        }
        .padding(.horizontal, BuzzSpacing.lg)
    }

    private func membersSection(_ org: Organization) -> some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            HStack {
                Text("Members")
                    .font(BuzzFont.headline)
                    .foregroundStyle(BuzzColor.textPrimary)
                Spacer()
                if let uid = currentUserID, viewModel?.canManage(currentUserID: uid) == true {
                    Button {
                        Haptics.tap()
                        showingInviteSheet = true
                    } label: {
                        Label("Invite", systemImage: "person.badge.plus")
                            .font(BuzzFont.captionBold)
                            .foregroundStyle(.black)
                            .padding(.horizontal, BuzzSpacing.md)
                            .padding(.vertical, BuzzSpacing.xs)
                            .background(Capsule().fill(org.accent))
                    }
                    .buttonStyle(.plain)
                    TablingLaunchButton(organization: org)
                }
            }
            ForEach(viewModel?.membersSorted ?? [], id: \.1.id) { profile, membership in
                MemberRow(profile: profile, membership: membership, organization: org)
                if membership.id != viewModel?.membersSorted.last?.1.id {
                    Divider().background(BuzzColor.border)
                }
            }
        }
        .padding(.horizontal, BuzzSpacing.lg)
    }

    private func eventsSection(_ org: Organization) -> some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            Text("Upcoming events")
                .font(BuzzFont.headline)
                .foregroundStyle(BuzzColor.textPrimary)
            if viewModel?.events.isEmpty ?? true {
                Text("Nothing scheduled. Check back soon.")
                    .font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textTertiary)
            } else {
                ForEach(viewModel?.events ?? []) { event in
                    OrganizationEventRow(event: event)
                }
            }
        }
        .padding(.horizontal, BuzzSpacing.lg)
    }
}
