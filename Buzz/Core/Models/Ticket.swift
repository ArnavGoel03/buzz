import Foundation

struct TicketType: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var eventID: UUID
    var name: String                         // "GA", "VIP", "Student"
    var priceCents: Int
    var currency: String                     // ISO 4217, default "USD"
    var quantityTotal: Int?                  // nil = unlimited
    var salesOpenAt: Date?
    var salesCloseAt: Date?
    var description: String?

    var priceDisplay: String {
        let amount = Double(priceCents) / 100.0
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currency
        return f.string(from: amount as NSNumber) ?? "\(currency) \(amount)"
    }

    var isFree: Bool { priceCents == 0 }
}

struct Ticket: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var ticketTypeID: UUID
    var buyerID: UUID
    var stripeSessionID: String?
    var pricePaidCents: Int
    var status: TicketStatus
    var qrToken: String
    var purchasedAt: Date
    var usedAt: Date?
}

enum TicketStatus: String, Codable, CaseIterable, Hashable, Sendable {
    case pending, paid, refunded, used
}
