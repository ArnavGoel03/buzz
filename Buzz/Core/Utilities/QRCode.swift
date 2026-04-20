import SwiftUI
import CoreImage.CIFilterBuiltins

/// Generates a QR code for a string (typically a `BuzzLink` URL). Renders large enough to be
/// printable at poster sizes — clubs put up ONE QR poster instead of stacks of paper flyers.
enum QRCode {
    // VULN #97 patch: a single shared CIContext across calls. CIContext init is expensive
    // (~50ms first call), so creating one per QR generation made tabling-mode janky on
    // first show. Now amortized.
    private static let context = CIContext(options: nil)

    @MainActor
    static func image(for string: String, scale: CGFloat = 12) -> Image? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "H"            // high error correction tolerates logo overlays + smudges
        guard let output = filter.outputImage?.transformed(by: .init(scaleX: scale, y: scale)),
              let cg = context.createCGImage(output, from: output.extent)
        else { return nil }
        return Image(decorative: cg, scale: 1.0, orientation: .up)
    }
}
