import Foundation

struct TextbookListing: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var sellerID: UUID
    var campus: String
    var isbn: String?
    var title: String
    var author: String?
    var edition: String?
    var courseCode: String?
    var priceCents: Int
    var condition: TextbookCondition
    var photoURLs: [URL]
    var status: Status
    var createdAt: Date

    enum Status: String, Codable, Hashable, Sendable { case available, pending, sold }

    var priceDisplay: String {
        let f = NumberFormatter(); f.numberStyle = .currency; f.currencyCode = "USD"
        return f.string(from: NSNumber(value: Double(priceCents) / 100.0)) ?? "$\(priceCents / 100)"
    }
}

enum TextbookCondition: String, Codable, CaseIterable, Hashable, Sendable {
    case new, likeNew = "like_new", good, acceptable, annotated

    var displayName: String {
        switch self {
        case .new: "New"
        case .likeNew: "Like new"
        case .good: "Good"
        case .acceptable: "Acceptable"
        case .annotated: "Annotated"
        }
    }
}
