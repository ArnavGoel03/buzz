import SwiftUI

/// Reusable empty/loading/error overlay. Views call this in place of bespoke spinners or
/// "no data" text so the look is consistent and every state has a retry path.
struct LoadingStateView: View {
    let error: AppError?
    let isEmpty: Bool
    let emptyTitle: String
    let emptyBody: String
    let onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: BuzzSpacing.sm) {
            if let error {
                Image(systemName: symbol(for: error))
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(BuzzColor.textTertiary)
                Text(error.userMessage)
                    .font(BuzzFont.bodyEmphasis)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BuzzColor.textPrimary)
                if error.isRetryable, let onRetry {
                    Button {
                        Haptics.tap()
                        onRetry()
                    } label: {
                        Text("Try again")
                            .font(BuzzFont.captionBold)
                            .foregroundStyle(.black)
                            .padding(.horizontal, BuzzSpacing.md)
                            .padding(.vertical, BuzzSpacing.sm)
                            .background(Capsule().fill(BuzzColor.accent))
                    }
                    .buttonStyle(.plain)
                }
            } else if isEmpty {
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(BuzzColor.textTertiary)
                Text(emptyTitle)
                    .font(BuzzFont.headline)
                    .foregroundStyle(BuzzColor.textPrimary)
                Text(emptyBody)
                    .font(BuzzFont.caption)
                    .foregroundStyle(BuzzColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(BuzzSpacing.xl)
    }

    private func symbol(for error: AppError) -> String {
        switch error {
        case .offline: "wifi.slash"
        case .timedOut: "hourglass"
        case .backendDown: "exclamationmark.triangle.fill"
        case .notFound: "questionmark.circle"
        case .unauthorized: "lock.fill"
        case .rateLimited: "hourglass.bottomhalf.filled"
        case .decoding, .unknown: "exclamationmark.circle"
        }
    }
}
