import SwiftUI

enum EventCategory: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case party
    case academic
    case sports
    case food
    case club
    case arts
    case music
    case study
    case wellness

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .party: "Parties"
        case .academic: "Academic"
        case .sports: "Sports"
        case .food: "Free Food"
        case .club: "Clubs"
        case .arts: "Arts"
        case .music: "Music"
        case .study: "Study"
        case .wellness: "Wellness"
        }
    }

    var shortName: String {
        switch self {
        case .party: "Party"
        case .academic: "Lecture"
        case .sports: "Sports"
        case .food: "Food"
        case .club: "Club"
        case .arts: "Arts"
        case .music: "Music"
        case .study: "Study"
        case .wellness: "Wellness"
        }
    }

    var icon: String {
        switch self {
        case .party: "sparkles"
        case .academic: "graduationcap.fill"
        case .sports: "figure.run"
        case .food: "fork.knife"
        case .club: "person.3.fill"
        case .arts: "paintpalette.fill"
        case .music: "music.note"
        case .study: "books.vertical.fill"
        case .wellness: "heart.fill"
        }
    }

    var tint: Color {
        switch self {
        case .party:    Color(red: 1.00, green: 0.18, blue: 0.57)  // hot pink
        case .academic: Color(red: 0.04, green: 0.52, blue: 1.00)  // blue
        case .sports:   Color(red: 0.19, green: 0.82, blue: 0.35)  // green
        case .food:     Color(red: 1.00, green: 0.62, blue: 0.04)  // orange
        case .club:     Color(red: 0.75, green: 0.35, blue: 0.95)  // purple
        case .arts:     Color(red: 0.39, green: 0.82, blue: 1.00)  // teal
        case .music:    Color(red: 0.75, green: 0.95, blue: 0.20)  // lime
        case .study:    Color(red: 0.37, green: 0.36, blue: 0.90)  // indigo
        case .wellness: Color(red: 1.00, green: 0.45, blue: 0.45)  // coral
        }
    }
}
