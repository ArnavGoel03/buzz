package com.arnavgoel.buzz.data.repo

import com.arnavgoel.buzz.data.model.Event
import com.arnavgoel.buzz.data.model.Profile
import com.arnavgoel.buzz.data.model.RSVPStatus

/**
 * Mirrors iOS `EventRepository` protocol. Single source of truth for event data; both
 * Mock + Supabase implementations satisfy this so the UI never branches.
 */
interface EventsRepository {
    suspend fun eventsNear(latitude: Double, longitude: Double, radiusMeters: Double): List<Event>
    suspend fun event(id: String): Event?
    suspend fun rsvp(eventId: String, status: RSVPStatus)
    suspend fun myRsvps(): Map<String, RSVPStatus>
    suspend fun friendsGoing(eventId: String): List<Profile>
}
