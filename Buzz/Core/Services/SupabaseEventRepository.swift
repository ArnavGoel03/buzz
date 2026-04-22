import Foundation
import CoreLocation
import Supabase

/// Production EventRepository backed by Supabase. Swap `AppServices` init from
/// `MockEventRepository()` to `SupabaseEventRepository()` once TestFlight is ready.
///
/// Runs only on authenticated + anon sessions — RLS enforces the rest server-side.
/// Query shapes intentionally mirror `MockEventRepository` so views don't need to care
/// which repo is active.
actor SupabaseEventRepository: EventRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = BuzzSupabase.shared) {
        self.client = client
    }

    func events(near coordinate: CLLocationCoordinate2D, radiusMeters: Double) async throws -> [Event] {
        // Production: calls a PostGIS RPC `events_near(lat, lng, radius_m)` that joins
        // visibility rules + campus scoping into the query. Stubbed here — return [] so
        // the app boots cleanly against a fresh DB, then fill in after `supabase db push`
        // has landed the RPC in the project.
        let _: [Event] = try await client
            .from("events")
            .select()
            .limit(0)
            .execute()
            .value
        return []
    }

    func event(id: UUID) async throws -> Event? {
        return try? await client
            .from("events")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
    }

    func rsvp(eventID: UUID, status: RSVPStatus) async throws {
        // Calls server RPC `rsvp_to_event(event_id, status)` — it enforces the 200/user cap,
        // hidden-attendee rules, and the friends-going audit trail. Never write directly to
        // the RSVP table from the client.
        _ = try await client.rpc("rsvp_to_event", params: [
            "event_id": eventID.uuidString,
            "rsvp_status": status.rawValue
        ]).execute()
    }

    func myRSVPs() async throws -> [UUID: RSVPStatus] {
        // TODO: decode from `my_rsvps` view (RLS-scoped to auth.uid()).
        return [:]
    }

    func createEvent(_ event: Event) async throws -> Event {
        // The Postgres trigger `strip_event_official` nullifies any client-supplied
        // `is_official = true`. We mirror that in MockEventRepository too.
        var safe = event
        safe.isOfficial = false
        let inserted: Event = try await client
            .from("events")
            .insert(safe)
            .select()
            .single()
            .execute()
            .value
        return inserted
    }

    func friendsGoing(eventID: UUID) async throws -> [Profile] {
        // Hits the `friends_going_to_event(event_id)` RPC — RLS-gated, respects
        // `hide_attendees` per VULN #44.
        let rows: [Profile] = try await client.rpc("friends_going_to_event", params: [
            "event_id": eventID.uuidString
        ]).execute().value
        return rows
    }
}

/// Single shared Supabase client. Lazily built from Secrets.plist on first access.
/// Crash early if secrets are missing — better than silently falling back to a
/// pointless "empty app" state in a real build.
enum BuzzSupabase {
    static let shared: SupabaseClient = {
        let urlString = SecretsLoader.require(.supabaseURL)
        let anonKey   = SecretsLoader.require(.supabaseAnon)
        guard let url = URL(string: urlString) else {
            preconditionFailure("SUPABASE_URL in Secrets.plist is not a valid URL: \(urlString)")
        }
        return SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
    }()
}
