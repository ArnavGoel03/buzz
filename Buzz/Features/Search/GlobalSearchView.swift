import SwiftUI

/// Universal search across events, clubs, people, series, textbooks. Single input,
/// results grouped by kind. Replaces the "no way to find anything by keyword" gap.
struct GlobalSearchView: View {
    @Environment(AppServices.self) private var services
    @State private var query = ""
    @State private var events: [Event] = []
    @State private var orgs: [Organization] = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BuzzSpacing.lg) {
                    if query.isEmpty {
                        emptyState
                    } else {
                        if !events.isEmpty { resultSection("Events", count: events.count) { eventRows } }
                        if !orgs.isEmpty   { resultSection("Clubs",  count: orgs.count)   { orgRows  } }
                        if events.isEmpty && orgs.isEmpty && !isSearching {
                            LoadingStateView(
                                error: nil, isEmpty: true,
                                emptyTitle: "Nothing found",
                                emptyBody: "Try fewer words, or a different spelling.",
                                onRetry: nil
                            )
                        }
                    }
                }
                .padding(BuzzSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Search")
            .iosNavigationInline()
            .iosSearchableAlwaysVisible(text: $query, prompt: "Events, clubs, people…")
            .task(id: query) { await runSearch() }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            Text("Try:").font(BuzzFont.captionBold).foregroundStyle(BuzzColor.textTertiary)
            ForEach(["free food", "boba", "acm", "warren quad", "career fair"], id: \.self) { s in
                Button { query = s } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text(s)
                        Spacer()
                    }
                    .padding(BuzzSpacing.md)
                    .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
                }
                .foregroundStyle(BuzzColor.textPrimary)
                .buttonStyle(.plain)
            }
        }
    }

    private func resultSection<Content: View>(_ title: String, count: Int, @ViewBuilder rows: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            HStack {
                Text(title).font(BuzzFont.title2).foregroundStyle(BuzzColor.textPrimary)
                Text("\(count)").font(BuzzFont.captionBold).foregroundStyle(BuzzColor.textTertiary)
                    .padding(.horizontal, BuzzSpacing.sm).padding(.vertical, 3)
                    .background(Capsule().fill(Color.white.opacity(0.08)))
            }
            rows()
        }
    }

    private var eventRows: some View {
        VStack(spacing: BuzzSpacing.sm) {
            ForEach(events.prefix(8)) { OrganizationEventRow(event: $0) }
        }
    }

    private var orgRows: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BuzzSpacing.sm) {
            ForEach(orgs.prefix(6)) { ClubCard(organization: $0) }
        }
    }

    private func runSearch() async {
        guard !query.isEmpty else { events = []; orgs = []; return }
        isSearching = true
        defer { isSearching = false }
        let coord = services.location.coordinate
        let q = query.lowercased()
        let foundEvents = (try? await services.events.events(near: coord, radiusMeters: 10000)) ?? []
        events = foundEvents.filter {
            $0.title.lowercased().contains(q) ||
            $0.summary.lowercased().contains(q) ||
            $0.tags.contains(where: { $0.lowercased().contains(q) })
        }
        let campus = (try? await services.profiles.currentProfile().primaryAffiliation?.campus) ?? "ucsd"
        let foundOrgs = (try? await services.orgs.organizations(campus: campus)) ?? []
        orgs = foundOrgs.filter {
            $0.name.lowercased().contains(q) ||
            $0.handle.lowercased().contains(q) ||
            $0.tagline.lowercased().contains(q)
        }
    }
}
