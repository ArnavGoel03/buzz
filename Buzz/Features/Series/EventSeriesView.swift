import SwiftUI

/// "Homecoming Week" hub: hero banner, description, day-by-day schedule of all events
/// in the series. Turns a 12-event week into one discoverable destination.
struct EventSeriesView: View {
    let series: EventSeries
    let events: [Event]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BuzzSpacing.lg) {
                hero
                if let desc = series.description {
                    Text(desc)
                        .font(BuzzFont.body)
                        .foregroundStyle(BuzzColor.textSecondary)
                        .padding(.horizontal, BuzzSpacing.lg)
                }
                scheduleByDay
                    .padding(.horizontal, BuzzSpacing.lg)
            }
            .padding(.bottom, BuzzSpacing.xxl)
        }
        .scrollIndicators(.hidden)
        .background(BuzzColor.background.ignoresSafeArea())
        .iosNavigationInline()
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(LinearGradient(colors: [series.accent.opacity(0.7), .black],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 200)
            VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                Text(series.dateRange.uppercased())
                    .font(BuzzFont.micro).foregroundStyle(.white.opacity(0.8)).tracking(2)
                Text(series.name)
                    .font(BuzzFont.largeTitle).foregroundStyle(.white)
                    .lineLimit(2)
            }
            .padding(BuzzSpacing.lg)
        }
    }

    private var scheduleByDay: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.lg) {
            ForEach(groupedByDay.keys.sorted(), id: \.self) { day in
                VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
                    Text(formatDay(day))
                        .font(BuzzFont.headline).foregroundStyle(BuzzColor.textPrimary)
                    ForEach(groupedByDay[day] ?? []) { event in
                        OrganizationEventRow(event: event)
                    }
                }
            }
        }
    }

    private var groupedByDay: [Date: [Event]] {
        Dictionary(grouping: events.sorted(by: { $0.startsAt < $1.startsAt })) {
            Calendar.current.startOfDay(for: $0.startsAt)
        }
    }

    private func formatDay(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "EEEE, MMM d"; return f.string(from: d)
    }
}
