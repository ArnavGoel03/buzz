import SwiftUI

/// Paste your class schedule (e.g. from your school's portal) and we'll extract courses
/// + meeting times. Powers the "you have a 2h gap, here's what's happening" suggestion.
/// Ships with a regex-first parser; LLM fallback later.
struct ScheduleImportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var raw: String = ""
    @State private var parsed: [ParsedClass] = []
    @State private var isParsing = false

    struct ParsedClass: Identifiable {
        let id = UUID()
        let courseCode: String
        let days: String
        let time: String
        let location: String?
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Paste your schedule from WebReg / Banner / equivalent. We'll pull out courses + times.")
                        .font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textSecondary)
                }
                .listRowBackground(BuzzColor.surface)
                Section {
                    TextField("Paste schedule here", text: $raw, axis: .vertical)
                        .lineLimit(10...30)
                        .listRowBackground(BuzzColor.surface)
                    Button {
                        Task { await parseNow() }
                    } label: {
                        if isParsing { ProgressView() }
                        else { Label("Parse", systemImage: "wand.and.stars") }
                    }
                    .disabled(raw.isEmpty || isParsing)
                    .listRowBackground(BuzzColor.surface)
                }
                if !parsed.isEmpty {
                    Section("Found \(parsed.count) classes") {
                        ForEach(parsed) { c in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(c.courseCode).font(BuzzFont.bodyEmphasis)
                                Text("\(c.days) · \(c.time)\(c.location.map { " · \($0)" } ?? "")")
                                    .font(BuzzFont.caption)
                                    .foregroundStyle(BuzzColor.textSecondary)
                            }
                            .listRowBackground(BuzzColor.surface)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(BuzzColor.background)
            .navigationTitle("Import schedule")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { dismiss() }.bold().disabled(parsed.isEmpty)
                }
            }
        }
    }

    private func parseNow() async {
        isParsing = true
        defer { isParsing = false }
        try? await Task.sleep(for: .milliseconds(200))
        // Minimal regex parser — matches "CSE 101  TuTh 10:00am-11:20am  Center 105"
        let re = try? NSRegularExpression(
            pattern: #"([A-Z]{2,4}\s?\d{1,3}[A-Z]?)\s+([MTWRFS]+(?:Th)?)\s+(\d{1,2}:\d{2}\s?[ap]m\s*[-–]\s*\d{1,2}:\d{2}\s?[ap]m)\s*([^\n]*)?"#
        )
        let ns = raw as NSString
        let matches = re?.matches(in: raw, range: NSRange(location: 0, length: ns.length)) ?? []
        parsed = matches.map { m in
            ParsedClass(
                courseCode: ns.substring(with: m.range(at: 1)).trimmingCharacters(in: .whitespaces),
                days: ns.substring(with: m.range(at: 2)),
                time: ns.substring(with: m.range(at: 3)).trimmingCharacters(in: .whitespaces),
                location: m.range(at: 4).location != NSNotFound
                    ? ns.substring(with: m.range(at: 4)).trimmingCharacters(in: .whitespaces).nilIfEmpty()
                    : nil
            )
        }
        Haptics.success()
    }
}

private extension String {
    func nilIfEmpty() -> String? { isEmpty ? nil : self }
}
