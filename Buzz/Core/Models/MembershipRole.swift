import SwiftUI

enum MembershipRole: String, Codable, CaseIterable, Hashable, Sendable {
    // Prestige tier
    case founder
    case president
    case captain
    // Officer tier
    case vicePresident
    case treasurer
    case secretary
    case officer
    case lead
    // Member tier
    case member
    case alumni

    var displayName: String {
        switch self {
        case .founder: "Founder"
        case .president: "President"
        case .captain: "Captain"
        case .vicePresident: "Vice President"
        case .treasurer: "Treasurer"
        case .secretary: "Secretary"
        case .officer: "Officer"
        case .lead: "Lead"
        case .member: "Member"
        case .alumni: "Alumni"
        }
    }

    var tier: BadgeTier {
        switch self {
        case .founder, .president, .captain: .prestige
        case .vicePresident, .treasurer, .secretary, .officer, .lead: .officer
        case .member, .alumni: .member
        }
    }

    var icon: String {
        switch self {
        case .founder: "sparkles"
        case .president: "crown.fill"
        case .captain: "star.circle.fill"
        case .vicePresident: "star.fill"
        case .treasurer: "creditcard.fill"
        case .secretary: "pencil.and.list.clipboard"
        case .officer: "checkmark.seal.fill"
        case .lead: "bolt.fill"
        case .member: "person.fill"
        case .alumni: "clock.fill"
        }
    }
}

enum BadgeTier: Sendable {
    case member
    case officer
    case prestige
}
