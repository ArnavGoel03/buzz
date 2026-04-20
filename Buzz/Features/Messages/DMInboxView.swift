import SwiftUI

/// Round 6 — inbox. Three thread kinds mixed: DMs, event groups, class groups. Last-
/// message preview + unread dot. Class groups are auto-created when two+ students share
/// a course import.
struct DMInboxView: View {
    @State private var threads: [ThreadRow] = []

    struct ThreadRow: Identifiable {
        let id: UUID
        let title: String
        let kind: Kind
        let lastMessage: String
        let lastTime: Date
        let unread: Bool
        enum Kind { case dm, eventGroup, classGroup }
    }

    var body: some View {
        NavigationStack {
            List(threads) { t in
                HStack(spacing: BuzzSpacing.md) {
                    icon(for: t.kind)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(t.title).font(BuzzFont.bodyEmphasis)
                            Spacer()
                            Text(relative(t.lastTime))
                                .font(BuzzFont.micro).foregroundStyle(BuzzColor.textTertiary)
                        }
                        Text(t.lastMessage)
                            .font(BuzzFont.caption)
                            .foregroundStyle(BuzzColor.textSecondary)
                            .lineLimit(1)
                    }
                    if t.unread {
                        Circle().fill(BuzzColor.accent).frame(width: 8, height: 8)
                    }
                }
                .listRowBackground(BuzzColor.surface)
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Messages")
            .iosNavigationInline()
        }
    }

    private func icon(for kind: ThreadRow.Kind) -> some View {
        let (sym, color) = switch kind {
        case .dm: ("person.fill", BuzzColor.accent)
        case .eventGroup: ("calendar", Color.pink)
        case .classGroup: ("graduationcap.fill", Color.blue)
        }
        return Image(systemName: sym)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(Circle().fill(color))
    }

    private func relative(_ d: Date) -> String {
        let f = RelativeDateTimeFormatter(); f.unitsStyle = .abbreviated
        return f.localizedString(for: d, relativeTo: Date())
    }
}
