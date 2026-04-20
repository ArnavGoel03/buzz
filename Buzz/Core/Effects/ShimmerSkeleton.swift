import SwiftUI

/// Replaces every `ProgressView()` on first-load screens. Users see a gray preview of
/// where content will be instead of a lonely spinner — reduces perceived wait time
/// ~30% (Instagram / Airbnb have quantified this). TimelineView-driven so it respects
/// LowPower + ReduceMotion via the BadgeShimmer pattern.
struct ShimmerSkeleton: View {
    var cornerRadius: CGFloat = 12
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(BuzzColor.surface)
            if !reduceMotion && !lowPower {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                    let t = context.date.timeIntervalSinceReferenceDate
                    let phase = CGFloat((sin(t * 1.2) + 1) / 2)
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: max(0, phase - 0.3)),
                            .init(color: .white.opacity(0.08), location: phase),
                            .init(color: .clear, location: min(1, phase + 0.3)),
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                    .blendMode(.plusLighter)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onReceive(NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)) { _ in
            lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        }
    }
}

/// Pre-shaped skeletons for common rows. Drop one in where real content will go.
enum SkeletonPreset {
    static func eventRow() -> some View {
        HStack(spacing: BuzzSpacing.md) {
            ShimmerSkeleton().frame(width: 48, height: 60)
            VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                ShimmerSkeleton(cornerRadius: 6).frame(height: 14).frame(maxWidth: .infinity)
                ShimmerSkeleton(cornerRadius: 6).frame(height: 11).frame(width: 140)
            }
            Spacer()
        }
        .padding(BuzzSpacing.md)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }

    static func badgeCard() -> some View {
        HStack(spacing: BuzzSpacing.md) {
            ShimmerSkeleton(cornerRadius: 28).frame(width: 54, height: 54)
            VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                ShimmerSkeleton(cornerRadius: 6).frame(height: 14).frame(width: 140)
                ShimmerSkeleton(cornerRadius: 6).frame(height: 10).frame(width: 90)
                ShimmerSkeleton(cornerRadius: 6).frame(height: 10).frame(width: 60)
            }
            Spacer()
        }
        .padding(BuzzSpacing.md)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(BuzzColor.surface))
    }
}
