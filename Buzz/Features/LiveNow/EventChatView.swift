import SwiftUI

/// Live event chat — the "is the line still long?" / "did the band start?" stream.
/// Anyone who can see the event can post; lightweight Q&A, not a DM thread.
struct EventChatView: View {
    let event: Event
    @State private var messages: [ChatMessage] = []
    @State private var draft = ""

    struct ChatMessage: Identifiable, Hashable {
        let id: UUID
        let authorName: String
        let text: String
        let createdAt: Date
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: BuzzSpacing.sm) {
                        ForEach(messages) { m in
                            messageBubble(m).id(m.id)
                        }
                    }
                    .padding(BuzzSpacing.lg)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            composer
        }
        .background(BuzzColor.background.ignoresSafeArea())
        .navigationTitle("Chat")
        .iosNavigationInline()
    }

    private func messageBubble(_ m: ChatMessage) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(m.authorName)
                .font(BuzzFont.micro)
                .foregroundStyle(BuzzColor.textTertiary)
            Text(m.text)
                .font(BuzzFont.body)
                .foregroundStyle(BuzzColor.textPrimary)
                .padding(.horizontal, BuzzSpacing.md)
                .padding(.vertical, BuzzSpacing.sm)
                .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
        }
    }

    private var composer: some View {
        HStack(spacing: BuzzSpacing.sm) {
            TextField("Ask the room…", text: $draft)
                .padding(.horizontal, BuzzSpacing.md)
                .padding(.vertical, BuzzSpacing.sm)
                .background(Capsule().fill(BuzzColor.surface))
            Button {
                guard !draft.isEmpty else { return }
                Haptics.tap()
                let m = ChatMessage(id: UUID(), authorName: "You", text: draft, createdAt: Date())
                messages.append(m)
                draft = ""
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(draft.isEmpty ? BuzzColor.textTertiary : BuzzColor.accent)
            }
            .buttonStyle(.plain)
            .disabled(draft.isEmpty)
        }
        .padding(BuzzSpacing.md)
        .background(BuzzColor.background.opacity(0.95))
        .overlay(Rectangle().fill(BuzzColor.border).frame(height: 1), alignment: .top)
    }
}
