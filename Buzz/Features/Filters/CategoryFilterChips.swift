import SwiftUI

struct CategoryFilterChips: View {
    @Binding var selected: Set<EventCategory>
    let onToggle: (EventCategory) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BuzzSpacing.sm) {
                ForEach(EventCategory.allCases) { category in
                    FilterChip(
                        label: category.shortName,
                        icon: category.icon,
                        tint: category.tint,
                        isActive: selected.contains(category),
                        action: { onToggle(category) }
                    )
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
        }
    }
}
