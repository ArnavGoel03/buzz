import SwiftUI

/// Photo strip from an event — Instagram-Story-style horizontal scroll on the event
/// detail sheet. Builds the FOMO loop: people who didn't go see what they missed.
struct EventStoriesRow: View {
    let photos: [EventPhoto]
    let onTapAdd: () -> Void
    let viewerAttended: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            HStack {
                Text("Photos from this event")
                    .font(BuzzFont.headline)
                    .foregroundStyle(BuzzColor.textPrimary)
                Spacer()
                if viewerAttended {
                    Button(action: onTapAdd) {
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(BuzzFont.captionBold)
                            .foregroundStyle(BuzzColor.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
            if photos.isEmpty {
                emptyState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: BuzzSpacing.sm) {
                        ForEach(photos) { photo in
                            photoTile(photo)
                        }
                    }
                }
            }
        }
    }

    private func photoTile(_ photo: EventPhoto) -> some View {
        AsyncImage(url: photo.imageURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Rectangle().fill(BuzzColor.surface)
        }
        .frame(width: 110, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium))
    }

    private var emptyState: some View {
        Text(viewerAttended
             ? "Be the first to share a photo from this event."
             : "No photos yet — only attendees can post.")
            .font(BuzzFont.caption)
            .foregroundStyle(BuzzColor.textTertiary)
            .padding(.vertical, BuzzSpacing.sm)
    }
}

struct EventPhoto: Identifiable, Hashable, Sendable {
    let id: UUID
    let imageURL: URL?
    let uploaderID: UUID
    let caption: String?
    let createdAt: Date
}
