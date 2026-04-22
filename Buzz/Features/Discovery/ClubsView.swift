import SwiftUI

struct ClubsView: View {
    @Environment(AppServices.self) private var services
    @Environment(AuthSession.self) private var auth
    @State private var viewModel: ClubsViewModel?

    private let columns = [
        GridItem(.flexible(), spacing: BuzzSpacing.md),
        GridItem(.flexible(), spacing: BuzzSpacing.md)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                MetalGradientBackground(intensity: 0.5)
                    .overlay(BuzzColor.background.opacity(0.6))
                ScrollView {
                    VStack(alignment: .leading, spacing: BuzzSpacing.lg) {
                        hero
                            .padding(.horizontal, BuzzSpacing.lg)
                            .padding(.top, BuzzSpacing.sm)
                        search
                        categories
                        if let vm = viewModel, vm.query.isEmpty, vm.categoryFilter == nil {
                            TrendingClubsRail(orgs: vm.trending, buzzingOrgIDs: vm.buzzingOrgIDs)
                        }
                        grid
                        Spacer(minLength: BuzzSpacing.xxl)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .toolbar { ToolbarItem(placement: .principal) { WordmarkView(size: 20) } }
            .iosNavigationInline()
            .navigationDestination(for: UUID.self) { id in
                OrganizationView(organizationID: id)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = ClubsViewModel(orgs: services.orgs, events: services.events)
            }
            let campus = try? await services.profiles.currentProfile().primaryAffiliation?.campus
            await viewModel?.load(campus: campus ?? "ucsd", near: services.location.coordinate)
        }
        // VULN #110 patch: reset on auth change so we don't carry the previous user's
        // campus filter or cached results across an account switch.
        .onChange(of: auth.currentProfileID) { _, _ in
            viewModel = nil
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
            Text("CAMPUS · \(viewModel?.filtered.count ?? 0) ORGS")
                .font(BuzzFont.monoSmall)
                .tracking(1.4)
                .foregroundStyle(BuzzColor.textTertiary)
            RevealingText(text: "Clubs", font: BuzzFont.displayXL, foreground: BuzzColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var search: some View {
        if let vm = viewModel {
            ClubSearchBar(query: Binding(get: { vm.query }, set: { vm.query = $0 }))
                .padding(.horizontal, BuzzSpacing.lg)
        }
    }

    @ViewBuilder
    private var categories: some View {
        if let vm = viewModel {
            ClubCategoryBar(selected: Binding(
                get: { vm.categoryFilter },
                set: { vm.categoryFilter = $0 }
            ))
        }
    }

    @ViewBuilder
    private var grid: some View {
        if let vm = viewModel {
            LazyVGrid(columns: columns, spacing: BuzzSpacing.md) {
                ForEach(vm.filtered) { org in
                    NavigationLink(value: org.id) {
                        ClubCard(organization: org, isBuzzing: vm.isBuzzing(org))
                            .scrollRevealCard()
                            .magneticPress()
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
        }
    }

}
