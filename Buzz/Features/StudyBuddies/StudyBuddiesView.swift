import SwiftUI

/// "Anyone in CSE 101 want to study tonight?" One view lists upcoming study sessions
/// filtered to the user's imported class schedule. One tap to join.
struct StudyBuddiesView: View {
    @State private var sessions: [StudySession] = []
    @State private var showingCreate = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BuzzSpacing.md) {
                    header
                    if sessions.isEmpty {
                        LoadingStateView(
                            error: nil, isEmpty: true,
                            emptyTitle: "No study sessions yet",
                            emptyBody: "Start one. 90% of people are waiting for someone else to organize.",
                            onRetry: nil
                        )
                    } else {
                        ForEach(sessions) { session in
                            sessionCard(session)
                        }
                    }
                }
                .padding(BuzzSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Study")
            .iosNavigationInline()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button { showingCreate = true } label: {
                        Image(systemName: "plus.circle.fill").foregroundStyle(BuzzColor.accent)
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
            Text("Sessions for your classes")
                .font(BuzzFont.title)
                .foregroundStyle(BuzzColor.textPrimary)
            Text("Pulled from your schedule. Filter with the search tab.")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
        }
    }

    private func sessionCard(_ s: StudySession) -> some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            HStack {
                Text(s.courseCode).font(BuzzFont.captionBold)
                    .foregroundStyle(.black)
                    .padding(.horizontal, BuzzSpacing.sm).padding(.vertical, 4)
                    .background(Capsule().fill(BuzzColor.accent))
                Spacer()
                Text(s.startsAt.friendlyStart())
                    .font(BuzzFont.caption).foregroundStyle(BuzzColor.textSecondary)
            }
            if let notes = s.notes {
                Text(notes).font(BuzzFont.body).foregroundStyle(BuzzColor.textPrimary)
            }
            HStack(spacing: BuzzSpacing.sm) {
                if let loc = s.location {
                    Label(loc, systemImage: "mappin")
                        .font(BuzzFont.caption)
                        .foregroundStyle(BuzzColor.textSecondary)
                }
                Spacer()
                Text("\(s.rsvpCount)/\(s.maxPeople ?? 10) in")
                    .font(BuzzFont.captionBold)
                    .foregroundStyle(BuzzColor.textPrimary)
            }
        }
        .padding(BuzzSpacing.md)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }
}

struct StudySession: Identifiable, Sendable {
    let id: UUID
    var organizerID: UUID
    var courseCode: String
    var campus: String
    var startsAt: Date
    var endsAt: Date
    var location: String?
    var maxPeople: Int?
    var notes: String?
    var rsvpCount: Int
}
