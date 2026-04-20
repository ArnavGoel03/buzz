import SwiftUI
#if os(iOS)
import ARKit
import RealityKit
import CoreLocation
#endif

#if os(iOS)

/// "Point your phone at a building, see what's happening there tonight." Pure iOS
/// feature — ARKit + camera. Gated via `#if os(iOS)` so the whole file compiles out
/// on macOS + visionOS where ARKit isn't available the way this view expects.
struct ARLookAroundView: View {
    @Environment(AppServices.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var events: [Event] = []

    var body: some View {
        ZStack(alignment: .bottom) {
            ARContainer(events: events, userCoord: services.location.coordinate)
                .ignoresSafeArea()
            bottomCard
                .padding(BuzzSpacing.lg)
        }
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(BuzzSpacing.lg)
            }
        }
        .task { await load() }
    }

    private var bottomCard: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
            Label("Look around", systemImage: "dot.viewfinder")
                .font(BuzzFont.captionBold)
                .foregroundStyle(BuzzColor.accent)
            Text("Point your phone at a building. Event pins anchor to their real-world locations.")
                .font(BuzzFont.caption)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(BuzzSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: BuzzSpacing.cornerMedium).fill(.black.opacity(0.55)))
    }

    private func load() async {
        events = (try? await services.events.events(
            near: services.location.coordinate, radiusMeters: 500
        )) ?? []
    }
}

@MainActor
private struct ARContainer: UIViewRepresentable {
    let events: [Event]
    let userCoord: CLLocationCoordinate2D

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = []
        config.worldAlignment = .gravityAndHeading
        view.session.run(config)
        placeAnchors(in: view)
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        placeAnchors(in: uiView)
    }

    private func placeAnchors(in view: ARView) {
        view.scene.anchors.removeAll()
        for event in events.prefix(10) {
            let bearingMeters = offset(from: userCoord, to: event.coordinate)
            let anchor = AnchorEntity(world: SIMD3<Float>(bearingMeters.x, 0, bearingMeters.z))
            let text = MeshResource.generateText(
                event.title,
                extrusionDepth: 0.02,
                font: .systemFont(ofSize: 0.15, weight: .bold)
            )
            let mat = SimpleMaterial(color: .white, isMetallic: false)
            let entity = ModelEntity(mesh: text, materials: [mat])
            entity.scale = SIMD3<Float>(0.5, 0.5, 0.5)
            anchor.addChild(entity)
            view.scene.anchors.append(anchor)
        }
    }

    private func offset(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> SIMD3<Float> {
        let metersPerDegLat: Float = 111_320
        let metersPerDegLng = metersPerDegLat * Float(cos(a.latitude * .pi / 180))
        let dx = Float(b.longitude - a.longitude) * metersPerDegLng
        let dz = -Float(b.latitude - a.latitude) * metersPerDegLat
        return SIMD3<Float>(dx, 0, dz)
    }
}

#else

/// Stub for macOS / visionOS / any non-iOS platform so call sites compile.
struct ARLookAroundView: View {
    var body: some View {
        VStack(spacing: BuzzSpacing.md) {
            Image(systemName: "dot.viewfinder")
                .font(.system(size: 40))
                .foregroundStyle(BuzzColor.textTertiary)
            Text("AR Look Around is iPhone-only.")
                .font(BuzzFont.headline)
                .foregroundStyle(BuzzColor.textPrimary)
            Text("This feature uses ARKit. Open Buzz on your iPhone to see event anchors in the real world.")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BuzzSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BuzzColor.background)
    }
}

#endif
