import SwiftUI

/// Quick picker for the most common recurrence patterns. Generates an RFC 5545 RRULE
/// string compatible with both iCal export and the schema's `events.recurrence_rule`.
/// Power users can later edit the raw RRULE; 95% of clubs only need these presets.
struct RecurrenceRulePicker: View {
    @Binding var rule: String?

    enum Preset: String, CaseIterable, Identifiable {
        case none, daily, weekly, biweekly, monthly
        var id: String { rawValue }

        var label: String {
            switch self {
            case .none: "Doesn't repeat"
            case .daily: "Every day"
            case .weekly: "Every week"
            case .biweekly: "Every 2 weeks"
            case .monthly: "Monthly (same day)"
            }
        }

        var rrule: String? {
            switch self {
            case .none: nil
            case .daily: "FREQ=DAILY"
            case .weekly: "FREQ=WEEKLY"
            case .biweekly: "FREQ=WEEKLY;INTERVAL=2"
            case .monthly: "FREQ=MONTHLY"
            }
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BuzzSpacing.sm) {
                ForEach(Preset.allCases) { preset in
                    FilterChip(
                        label: preset.label,
                        icon: preset == .none ? "xmark.circle" : "repeat",
                        tint: BuzzColor.accent,
                        isActive: rule == preset.rrule,
                        action: {
                            Haptics.selection()
                            rule = preset.rrule
                        }
                    )
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
        }
    }
}
