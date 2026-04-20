import SwiftUI

/// Campus-wide lost & found. Segmented between "I lost" and "I found." Photo-first
/// so users scan visually for their AirPods / water bottle / backpack. Scoped to
/// verified campus members (RLS).
struct LostFoundView: View {
    @State private var filter: Filter = .all
    @State private var posts: [LostFoundPost] = []

    enum Filter: String, CaseIterable, Identifiable {
        case all, lost, found
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all: "All"
            case .lost: "Lost"
            case .found: "Found"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BuzzSpacing.md) {
                    Picker("", selection: $filter) {
                        ForEach(Filter.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    if visiblePosts.isEmpty {
                        LoadingStateView(
                            error: nil, isEmpty: true,
                            emptyTitle: "Nothing here",
                            emptyBody: "Post a photo of what you lost — or found. Campus notices fast.",
                            onRetry: nil
                        )
                    } else {
                        ForEach(visiblePosts) { post in
                            postCard(post)
                        }
                    }
                }
                .padding(BuzzSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Lost & Found")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Haptics.tap()
                    } label: {
                        Image(systemName: "plus.circle.fill").foregroundStyle(BuzzColor.accent)
                    }
                }
            }
        }
    }

    private var visiblePosts: [LostFoundPost] {
        switch filter {
        case .all: return posts
        case .lost: return posts.filter { $0.kind == .lost }
        case .found: return posts.filter { $0.kind == .found }
        }
    }

    private func postCard(_ post: LostFoundPost) -> some View {
        HStack(alignment: .top, spacing: BuzzSpacing.md) {
            if let url = post.photoURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(BuzzColor.surface)
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: BuzzSpacing.cornerSmall))
            } else {
                RoundedRectangle(cornerRadius: BuzzSpacing.cornerSmall)
                    .fill(post.kind == .lost ? BuzzColor.live.opacity(0.2) : BuzzColor.accent.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(Image(systemName: post.kind == .lost ? "magnifyingglass" : "hand.raised.fill"))
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: BuzzSpacing.xs) {
                    Text(post.kind.rawValue.uppercased())
                        .font(BuzzFont.micro).foregroundStyle(.black)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(post.kind == .lost ? BuzzColor.live : BuzzColor.accent))
                    Spacer()
                    Text(relativeTime(post.createdAt))
                        .font(BuzzFont.micro).foregroundStyle(BuzzColor.textTertiary)
                }
                Text(post.title).font(BuzzFont.bodyEmphasis).foregroundStyle(BuzzColor.textPrimary)
                if let loc = post.lastSeenLocation {
                    Text(loc).font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
                }
            }
            Spacer()
        }
        .padding(BuzzSpacing.md)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }

    private func relativeTime(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: date, relativeTo: Date())
    }
}

struct LostFoundPost: Identifiable, Sendable {
    let id: UUID
    var kind: Kind
    var title: String
    var description: String?
    var lastSeenLocation: String?
    var photoURL: URL?
    var createdAt: Date

    enum Kind: String, Sendable { case lost, found }
}
