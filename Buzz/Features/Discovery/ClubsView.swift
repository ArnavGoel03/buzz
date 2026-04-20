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
            ScrollView {
                VStack(spacing: BuzzSpacing.lg) {
                    search
                    categories
                    if let vm = viewModel, vm.query.isEmpty, vm.categoryFilter == nil {
                        TrendingClubsRail(orgs: vm.trending)
                    }
                    grid
                    Spacer(minLength: BuzzSpacing.xxl)
                }
                .padding(.top, BuzzSpacing.sm)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Clubs")
            .navigationDestination(for: UUID.self) { id in
                OrganizationView(organizationID: id)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = ClubsViewModel(orgs: services.orgs)
            }
            let campus = try? await services.profiles.currentProfile().primaryAffiliation?.campus
            await viewModel?.load(campus: campus ?? "ucsd")
        }
        // VULN #110 patch: reset on auth change so we don't carry the previous user's
        // campus filter or cached results across an account switch.
        .onChange(of: auth.currentProfileID) { _, _ in
            viewModel = nil
        }
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
                        ClubCard(organization: org)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
        }
    }

}
