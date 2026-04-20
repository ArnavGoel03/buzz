import SwiftUI

/// Configure outbound webhooks (Discord / Slack / generic) so the org's existing
/// chat channels announce events automatically when published.
struct WebhookSettingsSheet: View {
    let organization: Organization
    @Environment(\.dismiss) private var dismiss
    @State private var endpoints: [WebhookRow] = []
    @State private var newURL = ""
    @State private var newKind: Kind = .discord

    enum Kind: String, CaseIterable, Identifiable {
        case discord, slack, generic
        var id: String { rawValue }
        var label: String {
            switch self {
            case .discord: "Discord"
            case .slack: "Slack"
            case .generic: "Generic JSON"
            }
        }
        var systemImage: String {
            switch self {
            case .discord: "bubble.left.and.bubble.right.fill"
            case .slack: "number"
            case .generic: "globe"
            }
        }
    }

    struct WebhookRow: Identifiable {
        let id = UUID()
        let kind: Kind
        let url: String
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Existing webhooks") {
                    if endpoints.isEmpty {
                        Text("No webhooks yet. Add one below to auto-announce when you publish an event.")
                            .font(BuzzFont.caption)
                            .foregroundStyle(BuzzColor.textTertiary)
                    }
                    ForEach(endpoints) { ep in
                        HStack {
                            Image(systemName: ep.kind.systemImage)
                                .foregroundStyle(organization.accent)
                            VStack(alignment: .leading) {
                                Text(ep.kind.label).font(BuzzFont.bodyEmphasis)
                                Text(ep.url).font(BuzzFont.caption)
                                    .foregroundStyle(BuzzColor.textSecondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            Spacer()
                            Button {
                                endpoints.removeAll { $0.id == ep.id }
                                Haptics.warning()
                            } label: {
                                Image(systemName: "trash")
                            }
                            .foregroundStyle(BuzzColor.live)
                        }
                    }
                    .listRowBackground(BuzzColor.surface)
                }
                Section("Add webhook") {
                    Picker("Type", selection: $newKind) {
                        ForEach(Kind.allCases) { Text($0.label).tag($0) }
                    }
                    TextField("Webhook URL", text: $newURL)
                        .iosLowercaseInput()
                    Button {
                        guard URL(string: newURL)?.scheme == "https" else { return }
                        endpoints.append(WebhookRow(kind: newKind, url: newURL))
                        newURL = ""
                        Haptics.success()
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .disabled(newURL.isEmpty)
                }
                .listRowBackground(BuzzColor.surface)
            }
            .scrollContentBackground(.hidden)
            .background(BuzzColor.background)
            .navigationTitle("Webhooks")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() }.bold() }
            }
        }
    }
}
