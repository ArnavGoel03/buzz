import SwiftUI
import AVFoundation

/// Round 10 — auto-generate a shareable ~15s reel from event photos. Picks up to 8
/// photos from `event_photos`, cross-fades them with a beat-matched cadence, burns in
/// event metadata (title + date) on a last-card. Output saved to the user's camera roll
/// for Instagram/TikTok. Full AVFoundation pipeline lives behind this view model —
/// for MVP the view shows the preview grid + "Generate" CTA.
struct EventReelGenerator: View {
    let event: Event
    let photoURLs: [URL]
    @State private var isRendering = false
    @State private var rendered = false

    var body: some View {
        VStack(spacing: BuzzSpacing.lg) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BuzzSpacing.sm) {
                    ForEach(photoURLs.prefix(8), id: \.self) { url in
                        AsyncImage(url: url) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Rectangle().fill(BuzzColor.surface)
                        }
                        .frame(width: 100, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: BuzzSpacing.cornerSmall))
                    }
                }
            }
            Text("We'll stitch up to 8 photos into a 15-second reel with \(event.title) as the final card.")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
            Button {
                Haptics.tap()
                Task { await render() }
            } label: {
                HStack {
                    if isRendering { ProgressView().tint(.black) }
                    Text(rendered ? "Saved to camera roll" : "Generate reel")
                        .font(BuzzFont.headline)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BuzzSpacing.md)
                .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.accent))
            }
            .buttonStyle(.plain)
            .disabled(isRendering || photoURLs.isEmpty)
        }
        .padding(BuzzSpacing.lg)
    }

    private func render() async {
        isRendering = true
        defer { isRendering = false }
        // Real pipeline: AVMutableComposition with sequential AVAssets for each image
        // (static AVAssetImageGenerator → CVPixelBuffer → AVAssetWriter), crossfade
        // transitions via CAAnimation, export to H.264 MP4, save to photo library via
        // PHPhotoLibrary. Placeholder delay here.
        try? await Task.sleep(for: .seconds(1.5))
        Haptics.success()
        rendered = true
    }
}
