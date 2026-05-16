package com.arnavgoel.buzz.data.repo

import com.arnavgoel.buzz.data.model.Event
import com.arnavgoel.buzz.data.model.EventCategory
import com.arnavgoel.buzz.data.model.EventLocation
import com.arnavgoel.buzz.data.model.EventVisibility
import com.arnavgoel.buzz.data.model.Profile
import com.arnavgoel.buzz.data.model.RSVPStatus
import kotlinx.coroutines.delay
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.time.Instant

/**
 * Offline-only seed used in previews + emulator runs without `local.properties`. Mirrors
 * iOS `MockEventRepository` shape so the same UI flows render against either repo. Times
 * are computed relative to "now" so the seed stays evergreen.
 */
class MockEventsRepository : EventsRepository {
    private val mutex = Mutex()
    private val rsvps = mutableMapOf<String, RSVPStatus>()

    private fun seed(): List<Event> {
        val now = Instant.now().epochSecond
        return listOf(
            Event(
                id = "11111111-1111-1111-1111-111111111111",
                title = "AI x Founders Mixer",
                summary = "Coffee, demos, and chaotic energy. Bring your build.",
                category = EventCategory.ACADEMIC,
                startsAtEpochSec = now + 20 * 60,
                endsAtEpochSec = now + 3 * 3600,
                location = EventLocation("Geisel Library", "9500 Gilman Dr", 32.8811, -117.2376),
                hostName = "ACM at UCSD",
                rsvpCount = 87,
                tags = listOf("free food", "demos"),
                visibility = EventVisibility.PUBLIC_EVENT,
                isOfficial = false
            ),
            Event(
                id = "22222222-2222-2222-2222-222222222222",
                title = "Sigma Phi Rush — Day 3",
                summary = "Backyard mixer, dinner, mocks served.",
                category = EventCategory.PARTY,
                startsAtEpochSec = now - 30 * 60,
                endsAtEpochSec = now + 2 * 3600,
                location = EventLocation("Sigma Phi House", null, 32.8765, -117.2380),
                hostName = "Sigma Phi",
                rsvpCount = 142,
                tags = listOf("rush"),
                visibility = EventVisibility.PUBLIC_EVENT,
                isOfficial = false
            ),
            Event(
                id = "33333333-3333-3333-3333-333333333333",
                title = "Free Pizza @ Career Center",
                summary = "Resume reviews + Costco pizza. 200 slices on a first-come basis.",
                category = EventCategory.FOOD,
                startsAtEpochSec = now + 23 * 3600,
                endsAtEpochSec = now + 25 * 3600,
                location = EventLocation("Career Center", null, 32.8788, -117.2376),
                hostName = "Buzz Official",
                rsvpCount = 320,
                tags = listOf("free food", "drop-in"),
                visibility = EventVisibility.CAMPUS_ONLY,
                isOfficial = true
            ),
            Event(
                id = "44444444-4444-4444-4444-444444444444",
                title = "CSE 101 Study Jam",
                summary = "Anyone wrestling with dynamic programming? Bring a laptop.",
                category = EventCategory.STUDY,
                startsAtEpochSec = now + 6 * 3600,
                endsAtEpochSec = now + 9 * 3600,
                location = EventLocation("Geisel Floor 2", null, 32.8812, -117.2374),
                hostName = "Study Buddies",
                rsvpCount = 14,
                tags = listOf("study", "cse101"),
                visibility = EventVisibility.CAMPUS_ONLY,
                isOfficial = false
            )
        )
    }

    override suspend fun eventsNear(latitude: Double, longitude: Double, radiusMeters: Double): List<Event> {
        delay(120)
        return seed().sortedBy { it.startsAtEpochSec }
    }

    override suspend fun event(id: String): Event? = seed().firstOrNull { it.id == id }

    override suspend fun rsvp(eventId: String, status: RSVPStatus) {
        mutex.withLock { rsvps[eventId] = status }
    }

    override suspend fun myRsvps(): Map<String, RSVPStatus> = mutex.withLock { rsvps.toMap() }

    override suspend fun friendsGoing(eventId: String): List<Profile> = emptyList()
}
