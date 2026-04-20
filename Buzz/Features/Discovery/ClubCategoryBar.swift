import SwiftUI

struct ClubCategoryBar: View {
    @Binding var selected: OrganizationCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BuzzSpacing.sm) {
                FilterChip(
                    label: "All",
                    icon: "sparkles",
                    tint: BuzzColor.accent,
                    isActive: selected == nil,
                    action: { selected = nil; Haptics.selection() }
                )
                ForEach(OrganizationCategory.allCases) { cat in
                    FilterChip(
                        label: cat.displayName,
                        icon: cat.icon,
                        tint: BuzzColor.accent,
                        isActive: selected == cat,
                        action: { selected = cat; Haptics.selection() }
                    )
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
        }
    }
}
