import Foundation
import CoreLocation

/// A single accredited college or university — anywhere in the world. Keyed by a stable
/// slug (e.g. "ucsd", "iit-bombay", "oxford") used everywhere a campus is referenced —
/// in affiliations, events, and orgs.
///
/// **The registry is closed.** Users never type a campus name freely; they always pick
/// from a search/autocomplete UI populated from this registry. The Supabase schema enforces
/// this with a foreign key from every campus reference back to the `campuses` table —
/// the database rejects any unknown campus slug. Missing colleges are added via an admin
/// review queue (request flow), never by the end user.
///
/// Production seeding sources by country:
/// - US: IPEDS (NCES) — ~6,000 accredited institutions
/// - India: AISHE (Ministry of Education) — ~50,000 institutions
/// - UK: HESA — ~165 universities
/// - Plus per-country gov registries for CA, AU, DE, JP, KR, SG, BR, MX, etc.
struct Campus: Identifiable, Codable, Hashable, Sendable {
    let id: String                      // slug, e.g. "ucsd", "iit-bombay", "oxford"
    var displayName: String             // "UC San Diego"
    var shortName: String               // "UCSD"
    var country: String                 // ISO 3166-1 alpha-2, e.g. "US", "IN", "GB", "CA"
    var state: String                   // state/province/territory, may be empty
    var city: String                    // "La Jolla"
    var kind: CampusKind
    var domains: [String]               // institutional domains for OTP verification
    var preferredVerification: [VerificationMethod]   // ordered list of accepted methods
    var subCampuses: [SubCampus]        // residential colleges, hostels, etc.
    var latitude: Double?
    var longitude: Double?

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lng = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

enum CampusKind: String, Codable, CaseIterable, Hashable, Sendable {
    case communityCollege
    case fourYear
    case research
    case liberalArts
    case technical
    case hbcu
    case hsi
    case tribal
    case religious
    case military
    case graduateOnly
    case onlineOnly
}

struct SubCampus: Codable, Hashable, Sendable, Identifiable {
    var id: String                      // slug, e.g. "warren"
    var displayName: String             // "Earl Warren College"
}
