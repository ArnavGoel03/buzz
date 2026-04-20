import SwiftUI

/// Round 8 — professor directory with in-app reviews + office-hours lookup. Replaces
/// RateMyProfessor and the 17-page university directory PDF in one tap.
struct ProfessorDirectoryView: View {
    @State private var query = ""
    @State private var professors: [ProfSummary] = []

    struct ProfSummary: Identifiable {
        let id: UUID
        let name: String
        let department: String
        let rating: Double
        let reviewCount: Int
        let nextOfficeHour: Date?
    }

    var body: some View {
        NavigationStack {
            List(filtered) { p in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(p.name).font(BuzzFont.bodyEmphasis)
                        Spacer()
                        if p.rating > 0 {
                            Label(String(format: "%.1f", p.rating), systemImage: "star.fill")
                                .font(BuzzFont.captionBold)
                                .foregroundStyle(.yellow)
                        }
                    }
                    Text(p.department).font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
                    if let next = p.nextOfficeHour {
                        Label("Next office hour \(next.formatted(.relative(presentation: .numeric)))", systemImage: "clock.fill")
                            .font(BuzzFont.micro)
                            .foregroundStyle(BuzzColor.accent)
                    }
                }
                .listRowBackground(BuzzColor.surface)
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Professors")
            .iosNavigationInline()
            .searchable(text: $query, prompt: "Name, department, course")
        }
    }

    private var filtered: [ProfSummary] {
        guard !query.isEmpty else { return professors }
        let q = query.lowercased()
        return professors.filter { $0.name.lowercased().contains(q) || $0.department.lowercased().contains(q) }
    }
}
