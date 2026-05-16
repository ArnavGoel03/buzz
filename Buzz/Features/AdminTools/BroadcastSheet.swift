import SwiftUI

/// Send a push / email blast to org members. Rate-limited server-side (5 per 24h per org).
struct BroadcastSheet: View {
    let organization: Organization
    let event: Event?
    @Environment(\.dismiss) private var dismiss
    @State private var subject = ""
    @State private var body_ = ""
    @State private var channel: Channel = .both
    @State private var isSending = false
    @State private var errorMessage: String?

    enum Channel: String, CaseIterable, Identifiable {
        case push, email, both
        var id: String { rawValue }
        var label: String {
            switch self {
            case .push: "Push"
            case .email: "Email"
            case .both: "Push + Email"
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                if let event {
                    Section {
                        Label("About: \(event.title)", systemImage: "calendar")
                            .foregroundStyle(BuzzColor.textSecondary)
                    }
                    .listRowBackground(BuzzColor.surface)
                }
                Section("Subject") {
                    TextField("Doors open in 30 min!", text: $subject)
                        .onChange(of: subject) { _, new in
                            if new.count > 120 { subject = String(new.prefix(120)) }
                        }
                        .listRowBackground(BuzzColor.surface)
                }
                Section("Message") {
                    TextField("…", text: $body_, axis: .vertical)
                        .lineLimit(3...8)
                        .onChange(of: body_) { _, new in
                            if new.count > 2000 { body_ = String(new.prefix(2000)) }
                        }
                        .listRowBackground(BuzzColor.surface)
                }
                Section("Channel") {
                    Picker("Channel", selection: $channel) {
                        ForEach(Channel.allCases) { c in Text(c.label).tag(c) }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(BuzzColor.surface)
                }
                Section {
                    Text("Members can mute org broadcasts in their Notifications settings. Buzz limits each org to 5 broadcasts per 24 hours.")
                        .font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textTertiary)
                }
                .listRowBackground(BuzzColor.surface)
            }
            .scrollContentBackground(.hidden)
            .background(BuzzColor.background)
            .navigationTitle("Broadcast")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await send() }
                    } label: {
                        if isSending { ProgressView() } else { Text("Send").bold() }
                    }
                    .disabled(subject.isEmpty || body_.isEmpty || isSending)
                }
            }
        }
    }

    private func send() async {
        isSending = true
        defer { isSending = false }
        // Hits /api/broadcast — server verifies officer role + invokes the rate-limit
        // trigger before fan-out. Surfaces failures so officers can retry; never fakes
        // success with a haptic on a broadcast they didn't actually send.
        do {
            let payload: [String: Any] = [
                "organization_id": organization.id.uuidString,
                "channel": channel.rawValue,
                "subject": subject,
                "body": body_,
            ]
            let url = URL(string: "https://buzz.app/api/broadcast")! // invariant: hardcoded host
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let jwt = try? await BuzzSupabase.shared.auth.session.accessToken {
                req.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
            }
            req.httpBody = try? JSONSerialization.data(withJSONObject: payload)
            let (_, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            Haptics.success()
            dismiss()
        } catch {
            Haptics.warning()
            errorMessage = "Couldn't send. \(error.localizedDescription)"
        }
    }
}
