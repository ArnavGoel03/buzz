import SwiftUI

enum OrganizationCategory: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case academic
    case greek
    case cultural
    case professional
    case service
    case sports
    case arts
    case religious
    case political
    case honor
    case interest

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .academic: "Academic"
        case .greek: "Greek Life"
        case .cultural: "Cultural"
        case .professional: "Professional"
        case .service: "Service"
        case .sports: "Sports & Rec"
        case .arts: "Arts"
        case .religious: "Religious"
        case .political: "Political"
        case .honor: "Honor Society"
        case .interest: "Interest"
        }
    }

    var icon: String {
        switch self {
        case .academic: "graduationcap.fill"
        case .greek: "building.columns.fill"
        case .cultural: "globe.asia.australia.fill"
        case .professional: "briefcase.fill"
        case .service: "hands.sparkles.fill"
        case .sports: "figure.run"
        case .arts: "paintpalette.fill"
        case .religious: "hands.and.sparkles.fill"
        case .political: "megaphone.fill"
        case .honor: "rosette"
        case .interest: "sparkles"
        }
    }
}
