import SwiftUI

struct TrendingClubsRail: View {
    let orgs: [Organization]

    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            HStack(spacing: BuzzSpacing.xs) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(BuzzColor.live)
                Text("Trending this week")
                    .font(BuzzFont.headline)
                    .foregroundStyle(BuzzColor.textPrimary)
            }
            .padding(.horizontal, BuzzSpacing.lg)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BuzzSpacing.md) {
                    ForEach(orgs) { org in
                        NavigationLink(value: org.id) {
                            ClubCard(organization: org)
                                .frame(width: 220)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, BuzzSpacing.lg)
            }
        }
    }
}
