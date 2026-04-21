import SwiftUI

struct ProfileView: View {
    @Environment(AppServices.self) private var services
    @Environment(AuthSession.self) private var auth
    @State private var viewModel: ProfileViewModel?
    @State private var showingSignIn = false
    @State private var path: [UUID] = []

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: BuzzSpacing.xl) {
                    // VULN #64 patch: never render the mock profile to a guest. The Profile
                    // tab in guest mode invites sign-in instead of showing some other user's data.
                    if !auth.isAuthenticated {
                        guestPrompt
                    } else if let profile = viewModel?.profile, let vm = viewModel {
                        ProfileHeader(profile: profile)
                        PendingInvitesSection(
                            invites: vm.pendingInvites,
                            orgsByID: vm.orgsByID,
                            onRespond: { id, accept in
                                Task { await vm.respondToInvite(id, accept: accept) }
                            }
                        )
                        BadgeCollection(
                            memberships: vm.activeMemberships,
                            orgsByID: vm.orgsByID,
                            onSelect: { m in
                                Haptics.tap()
                                vm.selectedMembershipID = m.id
                            }
                        )
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
            .iosHideNavigationBackground()
            // VULN #87 patch: actually navigate to the org page when "View [Org]" is tapped
            // from BadgeDetailSheet. Previously pendingOrgID was set but never consumed.
            .navigationDestination(for: UUID.self) { orgID in
                OrganizationView(organizationID: orgID)
            }
        }
        .onChange(of: viewModel?.pendingOrgID) { _, newValue in
            if let orgID = newValue {
                path.append(orgID)
                viewModel?.pendingOrgID = nil
            }
        }
        .task {
            guard auth.isAuthenticated else { return }
            if viewModel == nil {
                viewModel = ProfileViewModel(profiles: services.profiles, orgs: services.orgs)
            }
            await viewModel?.load()
        }
        // VULN #76 patch: when the auth state changes (sign-out, account switch), throw
        // away the cached view model so we don't briefly render the previous user's badges.
        .onChange(of: auth.currentProfileID) { _, _ in
            viewModel = nil
        }
        .sheet(isPresented: $showingSignIn) {
            SignInSheet()
                .presentationDetents([.medium, .large])
                .presentationBackground(.ultraThinMaterial)
        }
        .sheet(item: Binding(
            get: { viewModel?.selectedMembership },
            set: { new in viewModel?.selectedMembershipID = new?.id }
        )) { membership in
            if let vm = viewModel,
               let org = vm.orgsByID[membership.organizationID] {
                BadgeDetailSheet(
                    organization: org,
                    membership: membership,
                    onVisibilityChange: { v in
                        Task { await vm.setVisibility(v, for: membership.id) }
                    },
                    onOpenOrganization: {
                        vm.selectedMembershipID = nil
                        vm.pendingOrgID = org.id
                    }
                )
                .presentationDetents([.fraction(0.55), .large])
                .iosDragIndicator()
                .presentationBackground(.ultraThinMaterial)
            }
        }
    }

    private var guestPrompt: some View {
        VStack(spacing: BuzzSpacing.md) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(BuzzColor.accent)
                .padding(.top, BuzzSpacing.xxl)
            Text("Your profile lives here")
                .font(BuzzFont.title)
                .foregroundStyle(BuzzColor.textPrimary)
            Text("Sign in to RSVP, collect badges, and join clubs.")
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BuzzSpacing.xl)
            Button {
                Haptics.tap()
                showingSignIn = true
            } label: {
                Text("Get started — 3 taps")
                    .font(BuzzFont.headline)
                    .foregroundStyle(.black)
                    .padding(.horizontal, BuzzSpacing.xl)
                    .padding(.vertical, BuzzSpacing.md)
                    .background(Capsule().fill(BuzzColor.accent))
            }
            .buttonStyle(.plain)
            .padding(.top, BuzzSpacing.md)
        }
    }
}
