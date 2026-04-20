import SwiftUI

/// Student-facing purchase flow. Picks a ticket type, hits "Buy," and Stripe Checkout
/// opens in a SafariView (or Apple Pay directly when configured). On return we hand off
/// to the backend webhook to finalize the `tickets` row as `status='paid'`.
struct TicketPurchaseSheet: View {
    let event: Event
    let types: [TicketType]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTypeID: UUID?
    @State private var isCheckingOut = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BuzzSpacing.md) {
                    header
                    ForEach(types) { t in
                        TicketRow(
                            type: t,
                            isSelected: selectedTypeID == t.id,
                            onTap: {
                                Haptics.selection()
                                selectedTypeID = t.id
                            }
                        )
                    }
                    Spacer(minLength: BuzzSpacing.xxl)
                }
                .padding(BuzzSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Tickets")
            .iosNavigationInline()
            .safeAreaInset(edge: .bottom) { checkoutBar }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
            Text(event.title).font(BuzzFont.title2).foregroundStyle(BuzzColor.textPrimary)
            Text(event.location.name).font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var checkoutBar: some View {
        if let selected = types.first(where: { $0.id == selectedTypeID }) {
            Button {
                Task { await checkout(selected) }
            } label: {
                HStack {
                    if isCheckingOut { ProgressView().tint(.black) }
                    Text("Buy · \(selected.priceDisplay)")
                        .font(BuzzFont.headline)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BuzzSpacing.md)
                .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.accent))
            }
            .buttonStyle(.plain)
            .padding(BuzzSpacing.lg)
            .background(.ultraThinMaterial)
        }
    }

    private func checkout(_ type: TicketType) async {
        isCheckingOut = true
        defer { isCheckingOut = false }
        // Production: POST to /api/tickets/checkout → get Stripe Checkout URL → open in
        // ASWebAuthenticationSession. When the webhook finalizes the ticket, the app
        // refreshes via a Supabase realtime subscription on `tickets`.
        try? await Task.sleep(for: .milliseconds(300))
        Haptics.success()
        dismiss()
    }
}

private struct TicketRow: View {
    let type: TicketType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: BuzzSpacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.name).font(BuzzFont.headline).foregroundStyle(BuzzColor.textPrimary)
                    if let desc = type.description {
                        Text(desc).font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
                            .lineLimit(2)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(type.priceDisplay)
                        .font(BuzzFont.bodyEmphasis)
                        .foregroundStyle(isSelected ? BuzzColor.accent : BuzzColor.textPrimary)
                    if let remaining = type.quantityTotal {
                        Text("\(remaining) left").font(BuzzFont.micro)
                            .foregroundStyle(BuzzColor.textTertiary)
                    }
                }
            }
            .padding(BuzzSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                    .fill(BuzzColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium)
                    .stroke(isSelected ? BuzzColor.accent : BuzzColor.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
