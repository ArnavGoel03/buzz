import SwiftUI
import MapKit

struct MapView: View {
    @Environment(AppServices.self) private var services
    @Environment(AuthSession.self) private var auth
    @State private var viewModel: MapViewModel?
    @State private var camera: MapCameraPosition = .automatic

    var body: some View {
        ZStack(alignment: .top) {
            mapLayer
            overlays
        }
        .ignoresSafeArea(edges: .bottom)
        .task {
            if viewModel == nil {
                viewModel = MapViewModel(repository: services.events)
            }
            await viewModel?.load(near: services.location.coordinate)
            recenterOnUser()
        }
        // VULN #85 patch: reload feed when GPS gets a better fix.
        .onChange(of: services.location.coordinate.latitude) { _, _ in
            Task { await viewModel?.load(near: services.location.coordinate) }
        }
        // VULN #110 patch: drop the cached viewModel on auth change so the next user
        // doesn't see the previous user's events / RSVPs.
        .onChange(of: auth.currentProfileID) { _, _ in
            viewModel = nil
        }
        .sheet(item: Binding(
            get: { viewModel?.selectedEvent },
            set: { new in viewModel?.selectedEventID = new?.id }
        )) { event in
            if let vm = viewModel {
                EventDetailSheet(event: event, viewModel: vm)
                    .presentationDetents([.fraction(0.45), .large])
                    .iosDragIndicator()
                    .presentationBackground(.ultraThinMaterial)
            }
        }
    }

    private var mapLayer: some View {
        Map(position: $camera, selection: Binding(
            get: { viewModel?.selectedEventID },
            set: { viewModel?.selectedEventID = $0 }
        )) {
            UserAnnotation()
            if let vm = viewModel {
                ForEach(vm.filteredEvents) { event in
                    Annotation(event.title, coordinate: event.coordinate) {
                        EventPin(event: event, isSelected: vm.selectedEventID == event.id)
                            .onTapGesture {
                                Haptics.tap()
                                vm.selectedEventID = event.id
                            }
                    }
                    .tag(event.id)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .excludingAll, showsTraffic: false))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
    }

    @ViewBuilder
    private var overlays: some View {
        if let vm = viewModel {
            VStack(spacing: BuzzSpacing.md) {
                TimeFilterBar(selected: Binding(
                    get: { vm.timeFilter },
                    set: { new in
                        Haptics.selection()
                        vm.timeFilter = new
                    }
                ))
                CategoryFilterChips(
                    selected: Binding(
                        get: { vm.categoryFilter },
                        set: { vm.categoryFilter = $0 }
                    ),
                    onToggle: { cat in
                        Haptics.selection()
                        vm.toggleCategory(cat)
                    }
                )
            }
            .padding(.top, BuzzSpacing.sm)
        }
    }

    private func recenterOnUser() {
        camera = .region(MKCoordinateRegion(
            center: services.location.coordinate,
            latitudinalMeters: 1500,
            longitudinalMeters: 1500
        ))
    }
}
