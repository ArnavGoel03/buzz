import SwiftUI

/// Round 7 — .edu-verified deals. Local merchants + national SaaS (Spotify, Apple,
/// Adobe student discounts). Campus-scoped (national + your campus). Tap to redeem
/// (one-tap copy code + open merchant URL); we increment total_redemptions to track
/// partner success.
struct DealsView: View {
    @State private var category: Category = .all
    @State private var deals: [Deal] = []

    enum Category: String, CaseIterable, Identifiable {
        case all, food, apparel, software, entertainment, fitness, travel
        var id: String { rawValue }
        var label: String { rawValue.capitalized }
    }

    struct Deal: Identifiable {
        let id: UUID
        let merchantName: String
        let headline: String
        let body: String?
        let code: String?
        let category: Category
        let logoURL: URL?
        let expiresAt: Date?
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BuzzSpacing.md) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: BuzzSpacing.sm) {
                            ForEach(Category.allCases) { c in
                                FilterChip(label: c.label, icon: nil,
                                           tint: BuzzColor.accent, isActive: category == c,
                                           action: { category = c; Haptics.selection() })
                            }
                        }
                    }
                    ForEach(filtered) { deal in dealCard(deal) }
                }
                .padding(BuzzSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Deals")
            .iosNavigationInline()
        }
    }

    private var filtered: [Deal] {
        category == .all ? deals : deals.filter { $0.category == category }
    }

    private func dealCard(_ deal: Deal) -> some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            HStack {
                Text(deal.merchantName.uppercased())
                    .font(BuzzFont.micro).tracking(2)
                    .foregroundStyle(BuzzColor.textTertiary)
                Spacer()
                if let exp = deal.expiresAt {
                    Text("Ends \(exp.formatted(.relative(presentation: .numeric)))")
                        .font(BuzzFont.micro).foregroundStyle(BuzzColor.live)
                }
            }
            Text(deal.headline).font(BuzzFont.title2).foregroundStyle(BuzzColor.textPrimary)
            if let b = deal.body {
                Text(b).font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
            }
            if let code = deal.code {
                HStack {
                    Text(code).font(.system(.body, design: .monospaced)).foregroundStyle(BuzzColor.accent)
                    Spacer()
                    Label("Copy", systemImage: "doc.on.doc.fill")
                        .font(BuzzFont.captionBold).foregroundStyle(.black)
                        .padding(.horizontal, BuzzSpacing.md).padding(.vertical, 6)
                        .background(Capsule().fill(BuzzColor.accent))
                }
                .padding(BuzzSpacing.sm)
                .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerSmall).fill(BuzzColor.surface))
            }
        }
        .padding(BuzzSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerLarge)
                .fill(LinearGradient(colors: [BuzzColor.accent.opacity(0.15), BuzzColor.surface],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        )
    }
}
