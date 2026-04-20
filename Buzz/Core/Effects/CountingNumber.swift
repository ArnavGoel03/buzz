import SwiftUI

/// Counter that visually rolls from old value to new. SwiftUI's `.contentTransition(.numericText(...))`
/// + `.animation(...)` does the heavy lifting — we don't need the `Animatable` protocol,
/// which was causing a MainActor conformance crossover under Swift 6 strict concurrency.
struct CountingNumber: View {
    var value: Double
    var font: Font = BuzzFont.title
    var formatter: (Double) -> String = { String(Int($0)) }

    var body: some View {
        Text(formatter(value))
            .font(font)
            .contentTransition(.numericText(value: value))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: value)
    }
}

/// Convenience for integer counts.
struct CountingInt: View {
    let value: Int
    var font: Font = BuzzFont.bodyEmphasis

    var body: some View {
        Text("\(value)")
            .font(font)
            .contentTransition(.numericText(value: Double(value)))
            .animation(.spring(response: 0.45, dampingFraction: 0.75), value: value)
    }
}
