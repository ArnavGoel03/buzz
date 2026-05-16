import Foundation

/// Backs the invite-list builder + people-search sheets. Mirrors the iOS-side contract
/// used by `InviteListBuilderSheet` and `PeopleSearchSheet`. Production swaps the mock
/// for a Supabase-backed actor once the `org_invite_pool` view + `search_people` RPC ship.
protocol InvitesRepository: Sendable {
    func boardCount(of orgID: UUID) async throws -> Int
    func pastEvents(of orgID: UUID) async throws -> [Event]
    func resolveCount(sources: Set<InviteSource>) async throws -> Int
    func recentlyInvited() async throws -> [InvitePerson]
    func members(of orgID: UUID) async throws -> [InvitePerson]
    func search(query: String) async throws -> [InvitePerson]
}

/// Empty-by-default mock so the views render in previews + mock builds without a backend.
/// Real impl will hit Postgrest views scoped to the calling officer's org.
actor MockInvitesRepository: InvitesRepository {
    func boardCount(of orgID: UUID) async throws -> Int { 0 }
    func pastEvents(of orgID: UUID) async throws -> [Event] { [] }
    func resolveCount(sources: Set<InviteSource>) async throws -> Int {
        sources.reduce(0) { acc, src in
            switch src {
            case .allMembers(_, let n): acc + n
            case .boardOnly(_, let n): acc + n
            case .pastEventRSVPs(_, _, let n): acc + n
            case .customPerson: acc + 1
            }
        }
    }
    func recentlyInvited() async throws -> [InvitePerson] { [] }
    func members(of orgID: UUID) async throws -> [InvitePerson] { [] }
    func search(query: String) async throws -> [InvitePerson] { [] }
}
