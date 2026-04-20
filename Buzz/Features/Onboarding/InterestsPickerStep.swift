import SwiftUI

/// Between campus-picker and find-friends: "what do you care about?" Multi-select
/// category chips. Writes to `profile_interests` — drives the personalization ranker
/// (which events float to the top of the Live tab, which pushes fire, etc.)
struct InterestsPickerStep: View {
    @Binding var selected: Set<EventCategory>
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            Image(systemName: "sparkles")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(BuzzColor.accent)
                .padding(.top, BuzzSpacing.xl)
            Text("What's your vibe?")
                .font(BuzzFont.title)
                .foregroundStyle(BuzzColor.textPrimary)
            Text("Pick 3+ so the Live tab shows you the right stuff first. Change anytime.")
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BuzzSpacing.xl)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                          spacing: BuzzSpacing.md) {
                    ForEach(EventCategory.allCases) { cat in
                        chip(for: cat)
                    }
                }
                .padding(.horizontal, BuzzSpacing.lg)
            }
            .scrollIndicators(.hidden)

            Button {
                Haptics.success()
                onDone()
            } label: {
                Text(selected.count >= 3 ? "Continue" : "Pick \(3 - selected.count) more")
                    .font(BuzzFont.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BuzzSpacing.md)
                    .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                        .fill(selected.count >= 3 ? BuzzColor.accent : Color.white.opacity(0.12)))
            }
            .buttonStyle(.plain)
            .disabled(selected.count < 3)
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.bottom, BuzzSpacing.xl)
        }
        .background(BuzzColor.background.ignoresSafeArea())
    }

    private func chip(for cat: EventCategory) -> some View {
        let isOn = selected.contains(cat)
        return Button {
            Haptics.selection()
            if isOn { selected.remove(cat) } else { selected.insert(cat) }
        } label: {
            VStack(spacing: BuzzSpacing.xs) {
                Image(systemName: cat.icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(isOn ? Color.black : cat.tint)
                Text(cat.displayName)
                    .font(BuzzFont.caption)
                    .foregroundStyle(isOn ? Color.black : BuzzColor.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BuzzSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                    .fill(isOn ? cat.tint : BuzzColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                    .stroke(isOn ? Color.clear : cat.tint.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
