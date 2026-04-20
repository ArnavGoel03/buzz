import SwiftUI

/// The user's wallet of purchased tickets. Each shows a scannable QR for at-the-door
/// check-in. Apple Wallet export is a future add.
struct MyTicketsView: View {
    let tickets: [(Ticket, TicketType, Event)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BuzzSpacing.md) {
                    if tickets.isEmpty {
                        EmptyBadgesCard()
                    } else {
                        ForEach(tickets, id: \.0.id) { row in
                            TicketCard(ticket: row.0, type: row.1, event: row.2)
                        }
                    }
                }
                .padding(BuzzSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("My tickets")
            .iosNavigationInline()
        }
    }
}

private struct TicketCard: View {
    let ticket: Ticket
    let type: TicketType
    let event: Event

    var body: some View {
        VStack(spacing: BuzzSpacing.md) {
            VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                Text(event.title).font(BuzzFont.title2).foregroundStyle(BuzzColor.textPrimary)
                HStack(spacing: BuzzSpacing.sm) {
                    Label(type.name, systemImage: "ticket.fill")
                        .font(BuzzFont.captionBold)
                    if ticket.status == .used {
                        Text("USED").font(BuzzFont.micro)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(BuzzColor.textSecondary))
                            .foregroundStyle(BuzzColor.background)
                    }
                }
                .foregroundStyle(BuzzColor.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Divider().background(BuzzColor.border)
            qrImage
                .frame(width: 180, height: 180)
                .padding(BuzzSpacing.md)
                .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(.white))
            Text("Show this at the door")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
        }
        .padding(BuzzSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerLarge)
                .fill(LinearGradient(
                    colors: [event.category.tint.opacity(0.20), BuzzColor.surface],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
        )
        .overlay(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerLarge)
                .stroke(event.category.tint.opacity(0.4), lineWidth: 1)
        )
    }

    private var qrImage: some View {
        Group {
            if let img = QRCode.image(for: "buzz://ticket/\(ticket.id.uuidString)?t=\(ticket.qrToken)") {
                img.resizable().interpolation(.none).scaledToFit()
            } else {
                Image(systemName: "qrcode").resizable().scaledToFit()
            }
        }
    }
}
