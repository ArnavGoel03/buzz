package com.arnavgoel.buzz.data.repo

import com.arnavgoel.buzz.data.Buzz
import com.arnavgoel.buzz.data.model.Event
import com.arnavgoel.buzz.data.model.Profile
import com.arnavgoel.buzz.data.model.RSVPStatus
import io.github.jan.supabase.postgrest.from
import io.github.jan.supabase.postgrest.postgrest
import io.github.jan.supabase.postgrest.query.Columns
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject

/**
 * Production EventsRepository backed by Supabase Postgrest. Query shapes mirror the iOS
 * `SupabaseEventRepository` so server-side RPCs (`events_near`, `rsvp_to_event`,
 * `friends_going_to_event`) are the single source of truth for visibility + caps.
 */
class SupabaseEventsRepository : EventsRepository {
    override suspend fun eventsNear(latitude: Double, longitude: Double, radiusMeters: Double): List<Event> {
        return Buzz.supabase.postgrest.rpc(
            "events_near",
            buildJsonObject {
                put("lat", JsonPrimitive(latitude))
                put("lng", JsonPrimitive(longitude))
                put("radius_m", JsonPrimitive(radiusMeters))
            }
        ).decodeList<Event>()
    }

    override suspend fun event(id: String): Event? {
        return runCatching {
            Buzz.supabase
                .from("events")
                .select(Columns.ALL) { filter { eq("id", id) } }
                .decodeSingle<Event>()
        }.getOrNull()
    }

    override suspend fun rsvp(eventId: String, status: RSVPStatus) {
        val name = when (status) {
            RSVPStatus.NOT_GOING -> "notGoing"
            RSVPStatus.INTERESTED -> "interested"
            RSVPStatus.GOING -> "going"
        }
        Buzz.supabase.postgrest.rpc(
            "rsvp_to_event",
            buildJsonObject {
                put("event_id", JsonPrimitive(eventId))
                put("rsvp_status", JsonPrimitive(name))
            }
        )
    }

    override suspend fun myRsvps(): Map<String, RSVPStatus> {
        // TODO: decode from `my_rsvps` view (RLS-scoped to auth.uid()). Stubbed empty
        // so day-one builds work without the view present.
        return emptyMap()
    }

    override suspend fun friendsGoing(eventId: String): List<Profile> {
        return runCatching {
            Buzz.supabase.postgrest.rpc(
                "friends_going_to_event",
                buildJsonObject { put("event_id", JsonPrimitive(eventId)) }
            ).decodeList<Profile>()
        }.getOrDefault(emptyList())
    }
}
