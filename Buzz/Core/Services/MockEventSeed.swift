import Foundation

/// Tiny built-in fallback so previews and first-run are never empty, even without the JSON bundle.
enum MockEventSeed {
    static let fallback: [Event] = {
        let geisel = EventLocation(name: "Geisel Library", address: "9500 Gilman Dr, La Jolla, CA",
                                   latitude: 32.8812, longitude: -117.2374)
        let price = EventLocation(name: "Price Center West", address: "Price Center, UCSD",
                                  latitude: 32.8797, longitude: -117.2369)
        return [
            Event(id: UUID(), title: "Midnight Study w/ Free Boba",
                  summary: "Pulling an all-nighter? We brought the boba.",
                  category: .study, startsAt: Date().addingTimeInterval(1800),
                  endsAt: Date().addingTimeInterval(3600 * 6),
                  location: geisel, hostName: "CSE Honor Society",
                  capacity: 200, rsvpCount: 84, imageURL: nil,
                  tags: ["free food", "caffeine"], isOfficial: true),
            Event(id: UUID(), title: "Warren Quad Takeover",
                  summary: "DJ + food trucks + glow sticks. Come through.",
                  category: .party, startsAt: Date().addingTimeInterval(3600 * 3),
                  endsAt: Date().addingTimeInterval(3600 * 7),
                  location: price, hostName: "Warren College Council",
                  capacity: 500, rsvpCount: 312, imageURL: nil,
                  tags: ["DJ", "outdoor"], isOfficial: true),
        ]
    }()
}
