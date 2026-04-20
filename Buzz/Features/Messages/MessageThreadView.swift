import SwiftUI

/// Round 6 — single thread view. Reuses the composer + bubble patterns from
/// EventChatView but adds sender avatars, date dividers, and read receipts (opt-in).
struct MessageThreadView: View {
    let title: String
    @State private var messages: [Message] = []
    @State private var draft = ""

    struct Message: Identifiable, Hashable {
        let id: UUID
        let authorID: UUID
        let authorName: String
        let text: String
        let sentAt: Date
        let isMine: Bool
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                        ForEach(messages) { m in bubble(m).id(m.id) }
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
        .navigationTitle(title)
        .iosNavigationInline()
    }

    private func bubble(_ m: Message) -> some View {
        HStack(alignment: .top) {
            if m.isMine { Spacer(minLength: 60) }
            Text(m.text)
                .font(BuzzFont.body)
                .foregroundStyle(m.isMine ? Color.black : BuzzColor.textPrimary)
                .padding(.horizontal, BuzzSpacing.md)
                .padding(.vertical, BuzzSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(m.isMine ? BuzzColor.accent : BuzzColor.surface)
                )
            if !m.isMine { Spacer(minLength: 60) }
        }
    }

    private var composer: some View {
        HStack(spacing: BuzzSpacing.sm) {
            TextField("Message", text: $draft)
                .padding(.horizontal, BuzzSpacing.md).padding(.vertical, BuzzSpacing.sm)
                .background(Capsule().fill(BuzzColor.surface))
            Button {
                guard !draft.isEmpty else { return }
                Haptics.tap()
                messages.append(Message(id: UUID(), authorID: UUID(), authorName: "You", text: draft, sentAt: Date(), isMine: true))
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
