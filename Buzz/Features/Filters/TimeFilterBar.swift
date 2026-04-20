import SwiftUI

struct TimeFilterBar: View {
    @Binding var selected: TimeFilter

    var body: some View {
        HStack(spacing: BuzzSpacing.sm) {
            ForEach(TimeFilter.allCases) { filter in
                FilterChip(
                    label: filter.label,
                    icon: nil,
                    tint: BuzzColor.accent,
                    isActive: selected == filter,
                    action: { selected = filter }
                )
            }
        }
        .padding(.horizontal, BuzzSpacing.lg)
        .padding(.vertical, BuzzSpacing.sm)
        .background(
            Capsule().fill(.ultraThinMaterial)
        )
        .padding(.horizontal, BuzzSpacing.lg)
    }
}
