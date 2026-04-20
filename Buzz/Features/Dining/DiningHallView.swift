import SwiftUI

/// Round 3 — dining hall menus for today + "who's eating here" social layer.
/// Meal tab picker (breakfast / lunch / dinner / late night), station-grouped items,
/// dietary tags (vegan, gluten-free, halal). Data seeded from Nutrislice or the
/// school's dining API; for MVP it's manual/mock per-campus.
struct DiningHallView: View {
    let hallName: String
    let servingNow: String
    @State private var meal: Meal = .dinner
    @State private var menu: [MenuItem] = []
    @State private var friendsHere: [Profile] = []

    enum Meal: String, CaseIterable, Identifiable {
        case breakfast, lunch, dinner, latenight
        var id: String { rawValue }
        var label: String {
            switch self {
            case .breakfast: "Breakfast"
            case .lunch: "Lunch"
            case .dinner: "Dinner"
            case .latenight: "Late Night"
            }
        }
    }

    struct MenuItem: Identifiable {
        let id = UUID()
        let name: String
        let station: String
        let dietary: [String]    // "vegan", "gf", "halal"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BuzzSpacing.md) {
                    header
                    Picker("", selection: $meal) {
                        ForEach(Meal.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    friendsStrip
                    stationsList
                }
                .padding(BuzzSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle(hallName)
            .iosNavigationInline()
        }
    }

    private var header: some View {
        HStack {
            Label(servingNow, systemImage: "clock.fill")
                .font(BuzzFont.captionBold)
                .foregroundStyle(BuzzColor.accent)
            Spacer()
        }
    }

    @ViewBuilder
    private var friendsStrip: some View {
        if !friendsHere.isEmpty {
            HStack(spacing: -8) {
                ForEach(friendsHere.prefix(4)) { p in
                    ProfileAvatar(profile: p, size: 32)
                        .overlay(Circle().stroke(BuzzColor.background, lineWidth: 2))
                }
                Text("\(friendsHere.count) friends eating now")
                    .font(BuzzFont.captionBold)
                    .foregroundStyle(BuzzColor.textPrimary)
                    .padding(.leading, BuzzSpacing.md)
            }
            .padding(BuzzSpacing.sm)
            .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.accent.opacity(0.15)))
        }
    }

    private var stationsList: some View {
        let grouped = Dictionary(grouping: menu) { $0.station }
        return VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            ForEach(grouped.keys.sorted(), id: \.self) { station in
                VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                    Text(station).font(BuzzFont.headline).foregroundStyle(BuzzColor.textPrimary)
                    ForEach(grouped[station] ?? []) { item in
                        HStack {
                            Text(item.name).font(BuzzFont.body).foregroundStyle(BuzzColor.textPrimary)
                            Spacer()
                            ForEach(item.dietary, id: \.self) { tag in
                                Text(tag.uppercased()).font(BuzzFont.micro)
                                    .padding(.horizontal, 5).padding(.vertical, 2)
                                    .background(Capsule().fill(BuzzColor.accent.opacity(0.2)))
                                    .foregroundStyle(BuzzColor.accent)
                            }
                        }
                        .padding(.vertical, 3)
                    }
                }
                .padding(BuzzSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
            }
        }
    }
}
