import SwiftUI

/// Onboarding step 2: pick your campus. Autocomplete from the registry. If a nearby
/// campus was detected from location, it's pre-selected — user confirms with one tap.
struct CampusPickerStep: View {
    @Binding var selection: Campus?
    var suggested: Campus?
    @State private var query: String = ""
    @State private var results: [Campus] = []

    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            Text("Which campus?")
                .font(BuzzFont.title)
                .foregroundStyle(BuzzColor.textPrimary)
            Text("You can add more later — transfers, study abroad, grad school.")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)

            if let suggested, query.isEmpty {
                Button {
                    Haptics.success()
                    selection = suggested
                } label: {
                    HStack(spacing: BuzzSpacing.sm) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(BuzzColor.accent)
                        Text("Looks like you're at \(suggested.displayName)")
                            .font(BuzzFont.bodyEmphasis)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(selection?.id == suggested.id ? BuzzColor.accent : BuzzColor.textTertiary)
                    }
                    .padding(BuzzSpacing.md)
                    .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
                    .overlay(
                        RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                            .stroke(selection?.id == suggested.id ? BuzzColor.accent : BuzzColor.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            ClubSearchBar(query: $query)
                .onChange(of: query) { _, _ in search() }

            if !results.isEmpty {
                ScrollView {
                    LazyVStack(spacing: BuzzSpacing.sm) {
                        ForEach(results) { campus in
                            CampusResultRow(campus: campus, isSelected: selection?.id == campus.id) {
                                Haptics.selection()
                                selection = campus
                            }
                        }
                    }
                }
            }
        }
    }

    private func search() {
        let q = query.lowercased()
        guard !q.isEmpty else { results = []; return }
        results = CampusRegistry.all().filter { c in
            c.displayName.lowercased().contains(q)
            || c.shortName.lowercased().contains(q)
            || c.city.lowercased().contains(q)
        }
    }
}

private struct CampusResultRow: View {
    let campus: Campus
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: BuzzSpacing.sm) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(campus.displayName)
                        .font(BuzzFont.bodyEmphasis)
                        .foregroundStyle(BuzzColor.textPrimary)
                    Text("\(campus.city), \(campus.state.isEmpty ? campus.country : campus.state)")
                        .font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textSecondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(BuzzColor.accent)
                }
            }
            .padding(BuzzSpacing.md)
            .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
        }
        .buttonStyle(.plain)
    }
}
