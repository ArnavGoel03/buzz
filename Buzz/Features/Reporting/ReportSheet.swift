import SwiftUI

/// Single-screen report flow: pick a reason, optionally add a note, submit. Deliberately
/// short — if reporting is friction-heavy, users stop reporting and abuse wins.
struct ReportSheet: View {
    let target: ReportTarget
    @Environment(\.dismiss) private var dismiss
    @State private var reason: ReportReason?
    @State private var notes = ""
    @State private var submitting = false

    var body: some View {
        NavigationStack {
            List {
                Section("Why are you reporting this?") {
                    ForEach(ReportReason.allCases, id: \.self) { r in
                        Button {
                            Haptics.selection()
                            reason = r
                        } label: {
                            HStack {
                                Text(r.displayName)
                                    .foregroundStyle(BuzzColor.textPrimary)
                                Spacer()
                                if reason == r {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(BuzzColor.accent)
                                }
                            }
                        }
                        .listRowBackground(BuzzColor.surface)
                    }
                }
                Section("Notes (optional)") {
                    TextField("Anything the moderator should know?", text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                        .onChange(of: notes) { _, new in
                            // VULN #90 patch: cap to schema's 1000-char limit at the input
                            // layer so users don't waste typing.
                            if new.count > 1000 { notes = String(new.prefix(1000)) }
                        }
                        .listRowBackground(BuzzColor.surface)
                    if notes.count > 800 {
                        Text("\(1000 - notes.count) characters left")
                            .font(BuzzFont.micro)
                            .foregroundStyle(notes.count >= 1000 ? BuzzColor.live : BuzzColor.textTertiary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(BuzzColor.background)
            .navigationTitle("Report")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await submit() }
                    } label: {
                        if submitting { ProgressView() } else { Text("Send").bold() }
                    }
                    .disabled(reason == nil || submitting)
                }
            }
        }
    }

    private func submit() async {
        submitting = true
        defer { submitting = false }
        // Production: insert into public.reports via Supabase client. MVP: fire-and-forget.
        try? await Task.sleep(for: .milliseconds(200))
        Haptics.success()
        dismiss()
    }
}
