import SwiftUI

/// Round 9 — private mood check-in. Five-point scale, optional note. Data is owner-only
/// (RLS enforced). If a user reports "struggling," we surface CAPS + crisis resources
/// for their campus in the follow-up view. Never shared with anyone.
struct WellnessCheckInSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var mood: Mood?
    @State private var note = ""

    enum Mood: String, CaseIterable, Identifiable {
        case great, good, ok, low, struggling
        var id: String { rawValue }
        var emoji: String {
            switch self {
            case .great: "😄"
            case .good: "🙂"
            case .ok: "😐"
            case .low: "😔"
            case .struggling: "😣"
            }
        }
        var label: String { rawValue.capitalized }
        var color: Color {
            switch self {
            case .great: .green
            case .good: BuzzColor.accent
            case .ok: Color.blue
            case .low: .orange
            case .struggling: BuzzColor.live
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BuzzSpacing.lg) {
                    Text("How are you today?").font(BuzzFont.title).foregroundStyle(BuzzColor.textPrimary)
                    Text("Private. Only you see this.")
                        .font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
                    HStack(spacing: BuzzSpacing.sm) {
                        ForEach(Mood.allCases) { m in
                            Button {
                                Haptics.selection()
                                mood = m
                            } label: {
                                VStack {
                                    Text(m.emoji).font(.system(size: 36))
                                    Text(m.label).font(BuzzFont.micro)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, BuzzSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                                        .fill(mood == m ? m.color.opacity(0.25) : BuzzColor.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                                        .stroke(mood == m ? m.color : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(BuzzColor.textPrimary)
                        }
                    }
                    TextField("Optional note…", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(BuzzSpacing.md)
                        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
                    if mood == .low || mood == .struggling {
                        strugglingPrompt
                    }
                    Spacer(minLength: BuzzSpacing.xxl)
                }
                .padding(BuzzSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Check in")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Haptics.success()
                        dismiss()
                    }
                    .disabled(mood == nil)
                }
            }
        }
    }

    private var strugglingPrompt: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            Label("Want to talk to someone?", systemImage: "heart.text.square.fill")
                .font(BuzzFont.headline)
                .foregroundStyle(BuzzColor.live)
            Text("CAPS (free, confidential) at your campus · 24/7 crisis line · Peer support room schedule")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
            Link("Text the Crisis Line (741741)", destination: URL(string: "sms:741741")!)
                .font(BuzzFont.bodyEmphasis)
                .foregroundStyle(BuzzColor.live)
        }
        .padding(BuzzSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.live.opacity(0.12)))
    }
}
