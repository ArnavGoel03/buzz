import SwiftUI
import MapKit

/// Round 4 — live shuttle positions + ETAs at each stop. Pulls from `shuttle_positions`
/// via Supabase realtime (vehicles update every 10s). Buzz replaces the janky third-party
/// shuttle tracker every US campus ships with.
struct ShuttleMapView: View {
    let routes: [Route]
    let vehicles: [VehiclePosition]
    @State private var selectedRoute: UUID?
    @State private var livePulse = false

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
                liveStatusBar
                routePicker
                mapBody
            }
            .background(BuzzColor.background.ignoresSafeArea())
            .navigationTitle("Shuttles")
            .iosNavigationInline()
            .onAppear {
                withAnimation(.easeOut(duration: 1.4).repeatForever(autoreverses: false)) {
                    livePulse = true
                }
            }
        }
    }

    private var liveStatusBar: some View {
        HStack(spacing: BuzzSpacing.sm) {
            ZStack {
                Circle()
                    .fill(BuzzColor.live.opacity(0.35))
                    .frame(width: 14, height: 14)
                    .scaleEffect(livePulse ? 1.4 : 0.7)
                    .opacity(livePulse ? 0 : 0.85)
                Circle()
                    .fill(BuzzColor.live)
                    .frame(width: 6, height: 6)
            }
            Text("LIVE")
                .font(BuzzFont.micro)
                .tracking(1.6)
                .foregroundStyle(BuzzColor.live)
            Spacer()
            Text("\(visibleVehicles.count) on campus")
                .font(BuzzFont.mono)
                .foregroundStyle(BuzzColor.textSecondary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, BuzzSpacing.lg)
        .padding(.top, BuzzSpacing.sm)
        .padding(.bottom, BuzzSpacing.xs)
    }

    private var routePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BuzzSpacing.sm) {
                ForEach(routes) { route in
                    RouteChip(
                        route: route,
                        activeCount: vehicles.filter { $0.routeID == route.id }.count,
                        isSelected: selectedRoute == route.id,
                        onTap: {
                            Haptics.selection()
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                                selectedRoute = (selectedRoute == route.id) ? nil : route.id
                            }
                        }
                    )
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
                    ShuttleMarker(
                        tint: routeColor(for: v.routeID),
                        heading: v.heading,
                        label: routeLabel(for: v.routeID)
                    )
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .overlay(alignment: .center) {
            if visibleVehicles.isEmpty {
                emptyOverlay
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: visibleVehicles.isEmpty)
    }

    private var emptyOverlay: some View {
        VStack(spacing: BuzzSpacing.sm) {
            Text("Every shuttle is parked")
                .font(BuzzFont.bodyEmphasis)
                .foregroundStyle(BuzzColor.textPrimary)
            Text(selectedRoute == nil
                 ? "Routes nap overnight and between class blocks. Try again before classes let out."
                 : "This route's on a break — pick another, or see what else is rolling.")
                .font(BuzzFont.caption)
                .foregroundStyle(BuzzColor.textSecondary)
                .multilineTextAlignment(.center)
            if selectedRoute != nil {
                Button {
                    Haptics.selection()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                        selectedRoute = nil
                    }
                } label: {
                    Text("See all routes")
                        .font(BuzzFont.captionBold)
                        .foregroundStyle(.black)
                        .padding(.horizontal, BuzzSpacing.lg)
                        .padding(.vertical, BuzzSpacing.sm)
                        .frame(minHeight: 44)
                        .background(Capsule().fill(BuzzColor.accent))
                        .contentShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.top, BuzzSpacing.sm)
            }
        }
        .padding(BuzzSpacing.lg)
        .frame(maxWidth: 280)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: BuzzSpacing.cornerLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzSpacing.cornerLarge, style: .continuous)
                .strokeBorder(BuzzColor.border, lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.45), radius: 24, y: 8)
    }

    private var visibleVehicles: [VehiclePosition] {
        guard let sel = selectedRoute else { return vehicles }
        return vehicles.filter { $0.routeID == sel }
    }

    private func routeColor(for id: UUID) -> Color {
        routes.first(where: { $0.id == id })?.color ?? BuzzColor.accent
    }

    /// Derive a 1–2 char "route badge" from the route name — "Loop A" → "A",
    /// "Red Line" → "R", "North" → "N", "1" → "1". Mirrors how campus shuttles
    /// are actually painted, so riders recognize a bus without reading the chip.
    private func routeLabel(for id: UUID) -> String {
        guard let name = routes.first(where: { $0.id == id })?.name else { return "" }
        let parts = name.split(separator: " ")
        if let last = parts.last, last.count <= 2 {
            return String(last).uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }
}

/// Route filter chip — collapses dot, name, and live vehicle count into one capsule.
/// Empty routes dim down to tertiary so dead routes aren't visually competing with active ones.
/// Vertical padding hits the 44pt HIG tap target; full capsule is the hit shape so a pinky-edge
/// tap still registers.
private struct RouteChip: View {
    let route: ShuttleMapView.Route
    let activeCount: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let isDead = activeCount == 0
        Button(action: onTap) {
            HStack(spacing: 7) {
                Circle()
                    .fill(route.color)
                    .frame(width: 9, height: 9)
                    .opacity(isDead ? 0.45 : 1)
                Text(route.name)
                    .font(BuzzFont.captionBold)
                if !isDead {
                    Text("\(activeCount)")
                        .font(BuzzFont.monoSmall)
                        .foregroundStyle(isSelected ? Color.black.opacity(0.65) : BuzzColor.textSecondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            Capsule().fill(isSelected ? Color.black.opacity(0.12) : BuzzColor.background.opacity(0.5))
                        )
                }
            }
            .foregroundStyle(
                isSelected ? .black : (isDead ? BuzzColor.textTertiary : BuzzColor.textPrimary)
            )
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.vertical, BuzzSpacing.md)
            .frame(minHeight: 44)
            .background(
                Capsule().fill(isSelected ? route.color : BuzzColor.surface)
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? Color.clear : BuzzColor.border,
                    lineWidth: 0.5
                )
            )
            .shadow(color: isSelected ? route.color.opacity(0.45) : .clear, radius: 10, y: 2)
            .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// Tactile press feedback — scale + opacity dip while held. Used on every interactive
/// capsule on this screen so taps feel like they land instead of just toggling state.
private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

/// Top-down campus shuttle marker — a chunky little bus you can read at map zoom.
/// Heading rotates the chassis (so the amber headlight points the way the bus is moving),
/// while the route letter stays upright on the roof — same way real campus shuttles paint
/// their route designation, so riders ID a bus without reading any chip.
private struct ShuttleMarker: View {
    let tint: Color
    let heading: Double
    let label: String
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.22))
                .frame(width: 44, height: 44)
                .scaleEffect(pulse ? 1.15 : 0.9)
                .opacity(pulse ? 0 : 0.9)

            shuttleBody
                .rotationEffect(.degrees(heading))

            // Roof badge — counter-rotated against the chassis so the letter is always
            // upright regardless of travel direction. This is what makes the marker
            // legible on a moving map.
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.6), radius: 1.5, y: 0.5)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 0.5)
                    .background(
                        Capsule().fill(Color.black.opacity(0.55))
                    )
                    .overlay(
                        Capsule().strokeBorder(.white.opacity(0.22), lineWidth: 0.5)
                    )
            }
        }
        .shadow(color: tint.opacity(0.55), radius: 10, y: 2)
        .onAppear {
            withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }

    private var shuttleBody: some View {
        ZStack {
            // Chassis — glossy route-tinted gradient, top is the front of the bus
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [tint, tint.opacity(0.78)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 16, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 0.75)
                )

            // Windshield — wide tinted panel up front
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.white.opacity(0.55))
                .frame(width: 11, height: 4)
                .offset(y: -10)

            // Side windows — two rows that read as a shuttle, not a delivery van
            VStack(spacing: 2) {
                ForEach(0..<2, id: \.self) { _ in
                    HStack(spacing: 1.5) {
                        windowPane
                        windowPane
                    }
                }
            }
            .offset(y: -1)

            // Headlight — amber dot at the front, gives the marker its direction
            Circle()
                .fill(BuzzColor.accent)
                .frame(width: 3, height: 3)
                .offset(y: -13)
                .shadow(color: BuzzColor.accent.opacity(0.9), radius: 2)
        }
    }

    private var windowPane: some View {
        RoundedRectangle(cornerRadius: 1.2, style: .continuous)
            .fill(Color.white.opacity(0.32))
            .frame(width: 5, height: 4)
    }
}
