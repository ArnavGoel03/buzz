import SwiftUI

/// Officer-only analytics: published events, RSVPs, attendance, attendance-rate %.
/// Backed by the `org_analytics` view in Supabase.
struct OrgAnalyticsView: View {
    let organization: Organization
    @State private var stats: Stats = .placeholder

    struct Stats {
        var publishedEvents: Int
        var totalRSVPs: Int
        var totalAttendees: Int
        var activeMembers: Int
        var attendanceRatePct: Double?

        static let placeholder = Stats(
            publishedEvents: 24, totalRSVPs: 1280, totalAttendees: 940,
            activeMembers: 412, attendanceRatePct: 73.4
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: BuzzSpacing.lg) {
                grid
                bestTimeCard
            }
            .padding(BuzzSpacing.lg)
        }
        .background(BuzzColor.background.ignoresSafeArea())
        .navigationTitle("Analytics")
        .iosNavigationInline()
    }

    private var grid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: BuzzSpacing.md) {
            metric("Events", "\(stats.publishedEvents)", "calendar")
            metric("RSVPs", "\(stats.totalRSVPs)", "person.3.fill")
            metric("Attended", "\(stats.totalAttendees)", "checkmark.circle.fill")
            metric("Active members", "\(stats.activeMembers)", "person.2.fill")
            if let pct = stats.attendanceRatePct {
                metric("Attend rate", String(format: "%.1f%%", pct), "chart.bar.fill")
            }
            metric("Sheets saved", PaperImpact.friendly(PaperImpact.sheetsSaved(rsvps: stats.totalRSVPs)), "leaf.fill")
        }
    }

    private func metric(_ label: String, _ value: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(organization.accent)
                Spacer()
            }
            Text(value)
                .font(BuzzFont.title)
                .foregroundStyle(BuzzColor.textPrimary)
            Text(label)
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
        }
        .padding(BuzzSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }

    private var bestTimeCard: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
            Label("Best time to host", systemImage: "clock.fill")
                .font(BuzzFont.captionBold)
                .foregroundStyle(organization.accent)
            Text("Tuesday evenings 7–9 PM")
                .font(BuzzFont.title2)
                .foregroundStyle(BuzzColor.textPrimary)
            Text("Highest RSVP-to-attendance conversion among your past 12 events.")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
        }
        .padding(BuzzSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                .fill(LinearGradient(colors: [organization.accent.opacity(0.18), BuzzColor.surface],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        )
    }
}
