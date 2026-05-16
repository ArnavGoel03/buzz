import SwiftUI

/// Single-screen report flow: pick a reason, optionally add a note, submit. Deliberately
/// short — if reporting is friction-heavy, users stop reporting and abuse wins.
struct ReportSheet: View {
    let target: ReportTarget
    @Environment(\.dismiss) private var dismiss
    @State private var reason: ReportReason?
    @State private var notes = ""
    @State private var submitting = false
    @State private var errorMessage: String?

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
                                Text(r.displayName).foregroundStyle(BuzzColor.textPrimary)
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
                            if new.count > 1000 { notes = String(new.prefix(1000)) }
                        }
                        .listRowBackground(BuzzColor.surface)
                    if notes.count > 800 {
                        Text("\(1000 - notes.count) characters left")
                            .font(BuzzFont.micro)
                            .foregroundStyle(notes.count >= 1000 ? BuzzColor.live : BuzzColor.textTertiary)
                    }
                }
                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(BuzzColor.live) }
                        .listRowBackground(BuzzColor.surface)
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
        guard let reason else { return }
        let (kind, id): (String, UUID) = {
            switch target {
            case .event(let i):        return ("event", i)
            case .organization(let i): return ("organization", i)
            case .profile(let i):      return ("profile", i)
            }
        }()
        // Real insert into public.reports — never fire-and-forget on a safety surface.
        let payload: [String: String] = [
            "reason":     reason.rawValue,
            "target_id":  id.uuidString,
            "target_kind": kind,
            "notes":      notes,
        ]
        do {
            _ = try await BuzzSupabase.shared.from("reports").insert(payload).execute()
            Haptics.success()
            dismiss()
        } catch {
            Haptics.warning()
            errorMessage = "Couldn't submit your report. Try again."
        }
    }
}
