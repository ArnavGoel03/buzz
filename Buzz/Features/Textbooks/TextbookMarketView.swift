import SwiftUI

/// Campus textbook exchange. Scoped to your verified campus (RLS-enforced). Search +
/// filter by course code. Tap "List a book" to create one in under 30 sec.
struct TextbookMarketView: View {
    @State private var listings: [TextbookListing] = []
    @State private var query = ""
    @State private var showingListSheet = false

    private let columns = [GridItem(.flexible(), spacing: BuzzSpacing.md),
                           GridItem(.flexible(), spacing: BuzzSpacing.md)]

    var body: some View {
        NavigationStack {
            ScrollView {
                if filtered.isEmpty {
                    LoadingStateView(
                        error: nil, isEmpty: true,
                        emptyTitle: "No listings yet",
                        emptyBody: "Be the first — sell your CSE books before someone else does.",
                        onRetry: nil
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: BuzzSpacing.md) {
                        ForEach(filtered) { listing in
                            TextbookCard(listing: listing)
                        }
                    }
                    .padding(BuzzSpacing.lg)
                }
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Textbooks")
            .iosNavigationInline()
            .searchable(text: $query, prompt: "Title, author, or course code")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Haptics.tap()
                        showingListSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill").foregroundStyle(BuzzColor.accent)
                    }
                }
            }
        }
    }

    private var filtered: [TextbookListing] {
        guard !query.isEmpty else { return listings }
        let q = query.lowercased()
        return listings.filter {
            $0.title.lowercased().contains(q) ||
            $0.author?.lowercased().contains(q) == true ||
            $0.courseCode?.lowercased().contains(q) == true
        }
    }
}

struct TextbookCard: View {
    let listing: TextbookListing
    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
            Rectangle()
                .fill(LinearGradient(colors: [BuzzColor.accent.opacity(0.4), .black],
                                     startPoint: .top, endPoint: .bottom))
                .aspectRatio(0.72, contentMode: .fit)
                .overlay(
                    Image(systemName: "book.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.7))
                )
                .clipShape(RoundedRectangle(cornerRadius: BuzzSpacing.cornerSmall))
            Text(listing.title).font(BuzzFont.bodyEmphasis).foregroundStyle(BuzzColor.textPrimary).lineLimit(2)
            if let course = listing.courseCode {
                Text(course).font(BuzzFont.caption).foregroundStyle(BuzzColor.accent)
            }
            HStack {
                Text(listing.priceDisplay).font(BuzzFont.bodyEmphasis).foregroundStyle(BuzzColor.textPrimary)
                Spacer()
                Text(listing.condition.displayName).font(BuzzFont.micro).foregroundStyle(BuzzColor.textTertiary)
            }
        }
        .padding(BuzzSpacing.md)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }
}
