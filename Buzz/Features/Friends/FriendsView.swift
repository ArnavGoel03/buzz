import SwiftUI

/// Find & manage friends. Search by handle or display name. Pending requests at top,
/// then connected friends. Powers the social-proof layer everywhere.
struct FriendsView: View {
    @State private var query = ""
    @State private var pending: [Profile] = []
    @State private var friends: [Profile] = []
    @State private var suggestions: [Profile] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BuzzSpacing.lg) {
                    if !pending.isEmpty {
                        section("Friend requests") {
                            ForEach(pending) { p in
                                requestRow(p)
                            }
                        }
                    }
                    section("Your friends") {
                        if friends.isEmpty {
                            EmptyBadgesCard()
                        } else {
                            ForEach(friends) { p in friendRow(p) }
                        }
                    }
                    section("People at your campus") {
                        ForEach(suggestions) { p in suggestRow(p) }
                    }
                }
                .padding(.horizontal, BuzzSpacing.lg)
                .padding(.bottom, BuzzSpacing.xxl)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Friends")
            .iosNavigationInline()
            .searchable(text: $query, prompt: "Search by name or @handle")
        }
        .task { loadMockFriends() }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            Text(title)
                .font(BuzzFont.title2)
                .foregroundStyle(BuzzColor.textPrimary)
            content()
        }
    }

    private func requestRow(_ p: Profile) -> some View {
        HStack(spacing: BuzzSpacing.md) {
            ProfileAvatar(profile: p, size: 40)
            VStack(alignment: .leading, spacing: 1) {
                Text(p.displayName).font(BuzzFont.bodyEmphasis)
                Text(p.displayHandle).font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
            }
            Spacer()
            Button {
                Haptics.success()
                pending.removeAll { $0.id == p.id }
                friends.append(p)
            } label: {
                Text("Accept").font(BuzzFont.captionBold).foregroundStyle(.black)
                    .padding(.horizontal, BuzzSpacing.md).padding(.vertical, 6)
                    .background(Capsule().fill(BuzzColor.accent))
            }
            .buttonStyle(.plain)
            Button {
                Haptics.warning()
                pending.removeAll { $0.id == p.id }
            } label: {
                Image(systemName: "xmark").foregroundStyle(BuzzColor.textTertiary)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.white.opacity(0.06)))
            }
            .buttonStyle(.plain)
        }
        .padding(BuzzSpacing.md)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }

    private func friendRow(_ p: Profile) -> some View {
        HStack(spacing: BuzzSpacing.md) {
            ProfileAvatar(profile: p, size: 36)
            Text(p.displayName).font(BuzzFont.bodyEmphasis)
            Text(p.displayHandle).font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
            Spacer()
        }
        .padding(.vertical, BuzzSpacing.sm)
    }

    private func suggestRow(_ p: Profile) -> some View {
        HStack(spacing: BuzzSpacing.md) {
            ProfileAvatar(profile: p, size: 36)
            VStack(alignment: .leading, spacing: 1) {
                Text(p.displayName).font(BuzzFont.bodyEmphasis)
                Text(p.displayHandle).font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
            }
            Spacer()
            Button {
                Haptics.tap()
                suggestions.removeAll { $0.id == p.id }
            } label: {
                Label("Add", systemImage: "person.badge.plus").font(BuzzFont.captionBold)
                    .foregroundStyle(.black)
                    .padding(.horizontal, BuzzSpacing.md).padding(.vertical, 6)
                    .background(Capsule().fill(BuzzColor.accent))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, BuzzSpacing.sm)
    }

    private func loadMockFriends() {
        // Production: query friendships table for status='accepted' / 'pending'.
        // Mock: empty until real backend.
    }
}
