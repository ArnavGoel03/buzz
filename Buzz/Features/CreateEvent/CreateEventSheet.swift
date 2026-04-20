import SwiftUI
import MapKit

/// One-screen event creator. Smart defaults minimize typing:
///  - Host name = current profile's name
///  - Org = user's org (if they're an officer of exactly one)
///  - Starts = in 1 hour, rounded to the next :00/:30
///  - Ends   = 2 hours after start
///  - Visibility = campusOnly (safer default than public — anti-stalking)
///  - Location = current location as starting point
struct CreateEventSheet: View {
    @Environment(AppServices.self) private var services
    @Environment(\.dismiss) private var dismiss

    // Pre-filled context (passed from the caller)
    let hostProfile: Profile
    let hostOrganization: Organization?
    /// Optional source event for "duplicate" flow — pre-fills everything except date/time.
    var template: Event? = nil

    @State private var title = ""
    @State private var summary = ""
    @State private var category: EventCategory = .club
    @State private var startsAt: Date = .defaultStart()
    @State private var endsAt: Date = .defaultEnd()
    @State private var locationName = ""
    @State private var coordinate: CLLocationCoordinate2D = .init(latitude: 32.8812, longitude: -117.2374)
    @State private var capacity: String = ""
    @State private var visibility: EventVisibility = .campusOnly
    @State private var recurrenceRule: String? = nil
    @State private var coHostIDs: Set<UUID> = []
    @State private var showingCoHostPicker = false
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            Form {
                titleSection
                whenSection
                recurrenceSection
                whereSection
                detailsSection
                coHostSection
                privacySection
            }
            .scrollContentBackground(.hidden)
            .background(BuzzColor.background)
            .navigationTitle(template == nil ? "New event" : "Duplicate event")
            .iosNavigationInline()
            .toolbar { toolbar }
        }
        .task { applyTemplate() }
        .sheet(isPresented: $showingCoHostPicker) {
            if let org = hostOrganization {
                CoHostPickerSheet(selected: $coHostIDs, currentOrgID: org.id)
            }
        }
    }

    private func applyTemplate() {
        guard let t = template, title.isEmpty else { return }
        title = t.title
        summary = t.summary
        category = t.category
        locationName = t.location.name
        coordinate = t.coordinate
        capacity = t.capacity.map { String($0) } ?? ""
        visibility = t.visibility ?? .campusOnly
    }

    private var titleSection: some View {
        Section {
            TextField("Title", text: $title)
                .font(BuzzFont.title2)
            categoryPicker
        }
        .listRowBackground(BuzzColor.surface)
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BuzzSpacing.sm) {
                ForEach(EventCategory.allCases) { c in
                    FilterChip(
                        label: c.shortName, icon: c.icon, tint: c.tint,
                        isActive: category == c,
                        action: { Haptics.selection(); category = c }
                    )
                }
            }
        }
    }

    private var whenSection: some View {
        Section("When") {
            DatePicker("Starts", selection: $startsAt, displayedComponents: [.date, .hourAndMinute])
            DatePicker("Ends", selection: $endsAt, in: startsAt..., displayedComponents: [.date, .hourAndMinute])
        }
        .listRowBackground(BuzzColor.surface)
    }

    private var whereSection: some View {
        Section("Where") {
            TextField("Location name (e.g. Geisel Library)", text: $locationName)
        }
        .listRowBackground(BuzzColor.surface)
    }

    private var detailsSection: some View {
        Section("Details") {
            TextField("Short description (optional)", text: $summary, axis: .vertical)
                .lineLimit(2...4)
            TextField("Capacity (optional)", text: $capacity)
                .iosNumericKeyboard()
            if let org = hostOrganization {
                Label("Hosted by \(org.name)", systemImage: "person.3.fill")
                    .foregroundStyle(BuzzColor.textSecondary)
            }
        }
        .listRowBackground(BuzzColor.surface)
    }

    private var recurrenceSection: some View {
        Section("Repeat") {
            RecurrenceRulePicker(rule: $recurrenceRule)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
        }
    }

    private var coHostSection: some View {
        Section("Co-hosts") {
            Button {
                Haptics.tap()
                showingCoHostPicker = true
            } label: {
                HStack {
                    Image(systemName: "person.3.sequence.fill")
                    Text(coHostIDs.isEmpty ? "Add co-hosts (optional)" : "\(coHostIDs.count) co-host\(coHostIDs.count == 1 ? "" : "s")")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(BuzzColor.textTertiary)
                }
                .foregroundStyle(BuzzColor.textPrimary)
            }
            .disabled(hostOrganization == nil)
            .listRowBackground(BuzzColor.surface)
        }
    }

    private var privacySection: some View {
        Section("Who can see it") {
            Picker("Visibility", selection: $visibility) {
                Text("Everyone at my campus").tag(EventVisibility.campusOnly)
                Text("Only invited").tag(EventVisibility.inviteOnly)
                Text("Officers only").tag(EventVisibility.officersOnly)
                Text("Public (anyone on Buzz)").tag(EventVisibility.publicEvent)
            }
        }
        .listRowBackground(BuzzColor.surface)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button {
                Task { await publish() }
            } label: {
                if isSubmitting { ProgressView() } else { Text("Publish").bold() }
            }
            .disabled(!canPublish)
        }
    }

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
        && !locationName.trimmingCharacters(in: .whitespaces).isEmpty
        && !isSubmitting
    }

    private func publish() async {
        isSubmitting = true
        defer { isSubmitting = false }
        let event = Event(
            id: UUID(), title: title, summary: summary, category: category,
            startsAt: startsAt, endsAt: endsAt,
            location: EventLocation(
                name: locationName, address: nil,
                latitude: coordinate.latitude, longitude: coordinate.longitude
            ),
            hostName: hostOrganization?.name ?? hostProfile.displayName,
            organizationID: hostOrganization?.id,
            subCampus: hostProfile.primaryAffiliation?.subCampus,
            timezone: TimeZone.current.identifier,
            visibility: visibility,
            hideAttendees: visibility != .publicEvent,
            capacity: Int(capacity),
            rsvpCount: 0, imageURL: nil, tags: [], isOfficial: false
        )
        _ = try? await services.events.createEvent(event)
        Haptics.success()
        dismiss()
    }
}

private extension Date {
    static func defaultStart() -> Date {
        let cal = Calendar.current
        let future = Date().addingTimeInterval(3600)
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: future)
        var rounded = comps
        rounded.minute = (comps.minute ?? 0) >= 30 ? 30 : 0
        return cal.date(from: rounded) ?? future
    }

    static func defaultEnd() -> Date {
        defaultStart().addingTimeInterval(7200)
    }
}
