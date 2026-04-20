import SwiftUI
import MapKit

/// Round 4 — live shuttle positions + ETAs at each stop. Pulls from `shuttle_positions`
/// via Supabase realtime (vehicles update every 10s). Buzz replaces the janky third-party
/// shuttle tracker every US campus ships with.
struct ShuttleMapView: View {
    let routes: [Route]
    let vehicles: [VehiclePosition]
    @State private var selectedRoute: UUID?

    struct Route: Identifiable { let id: UUID; let name: String; let color: Color }
    struct VehiclePosition: Identifiable {
        let id: String
        let routeID: UUID
        let coordinate: CLLocationCoordinate2D
        let heading: Double
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                routePicker
                mapBody
            }
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Shuttles")
            .iosNavigationInline()
        }
    }

    private var routePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BuzzSpacing.sm) {
                ForEach(routes) { route in
                    Button {
                        Haptics.selection()
                        selectedRoute = (selectedRoute == route.id) ? nil : route.id
                    } label: {
                        HStack(spacing: 6) {
                            Circle().fill(route.color).frame(width: 8, height: 8)
                            Text(route.name).font(BuzzFont.captionBold)
                        }
                        .foregroundStyle(selectedRoute == route.id ? .black : BuzzColor.textPrimary)
                        .padding(.horizontal, BuzzSpacing.md).padding(.vertical, BuzzSpacing.sm)
                        .background(Capsule().fill(selectedRoute == route.id ? route.color : BuzzColor.surface))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.vertical, BuzzSpacing.sm)
        }
    }

    private var mapBody: some View {
        Map {
            ForEach(visibleVehicles) { v in
                Annotation("Shuttle", coordinate: v.coordinate) {
                    ZStack {
                        Circle().fill(routeColor(for: v.routeID))
                            .frame(width: 30, height: 30)
                            .shadow(color: routeColor(for: v.routeID).opacity(0.6), radius: 8)
                        Image(systemName: "bus.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .rotationEffect(.degrees(v.heading))
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
    }

    private var visibleVehicles: [VehiclePosition] {
        guard let sel = selectedRoute else { return vehicles }
        return vehicles.filter { $0.routeID == sel }
    }

    private func routeColor(for id: UUID) -> Color {
        routes.first(where: { $0.id == id })?.color ?? BuzzColor.accent
    }
}
