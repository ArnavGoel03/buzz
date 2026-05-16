package com.arnavgoel.buzz.data.model

import androidx.compose.ui.graphics.Color
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

@Serializable
data class Event(
    val id: String,
    val title: String,
    val summary: String = "",
    val category: EventCategory = EventCategory.CLUB,
    @SerialName("starts_at") val startsAtEpochSec: Long,
    @SerialName("ends_at") val endsAtEpochSec: Long,
    val location: EventLocation,
    @SerialName("host_name") val hostName: String = "",
    @SerialName("organization_id") val organizationId: String? = null,
    @SerialName("sub_campus") val subCampus: String? = null,
    val timezone: String? = null,
    val visibility: EventVisibility = EventVisibility.PUBLIC_EVENT,
    @SerialName("hide_attendees") val hideAttendees: Boolean = false,
    val capacity: Int? = null,
    @SerialName("rsvp_count") val rsvpCount: Int = 0,
    @SerialName("image_url") val imageUrl: String? = null,
    val tags: List<String> = emptyList(),
    @SerialName("is_official") val isOfficial: Boolean = false
) {
    fun urgencyAt(nowEpochSec: Long): EventUrgency = when {
        nowEpochSec > endsAtEpochSec -> EventUrgency.PAST
        nowEpochSec >= startsAtEpochSec -> EventUrgency.LIVE
        startsAtEpochSec - nowEpochSec <= 30 * 60 -> EventUrgency.STARTING
        startsAtEpochSec - nowEpochSec <= 24 * 3600 -> EventUrgency.SOON
        else -> EventUrgency.UPCOMING
    }

    fun isLiveAt(nowEpochSec: Long): Boolean =
        nowEpochSec in startsAtEpochSec..endsAtEpochSec
}

@Serializable
data class EventLocation(
    val name: String,
    val address: String? = null,
    val latitude: Double,
    val longitude: Double
)

@Serializable
enum class EventCategory(val displayName: String, val shortName: String, val tint: Color) {
    @SerialName("party")    PARTY("Parties", "Party", Color(0xFFFF2D92)),
    @SerialName("academic") ACADEMIC("Academic", "Lecture", Color(0xFF0A85FF)),
    @SerialName("sports")   SPORTS("Sports", "Sports", Color(0xFF30D158)),
    @SerialName("food")     FOOD("Free Food", "Food", Color(0xFFFF9F0A)),
    @SerialName("club")     CLUB("Clubs", "Club", Color(0xFFBF59F2)),
    @SerialName("arts")     ARTS("Arts", "Arts", Color(0xFF63D2FF)),
    @SerialName("music")    MUSIC("Music", "Music", Color(0xFFBFF233)),
    @SerialName("study")    STUDY("Study", "Study", Color(0xFF5E5CE6)),
    @SerialName("wellness") WELLNESS("Wellness", "Wellness", Color(0xFFFF7373))
}

@Serializable
enum class EventVisibility(val displayName: String) {
    @SerialName("publicEvent")  PUBLIC_EVENT("Public · anyone on Buzz"),
    @SerialName("campusOnly")   CAMPUS_ONLY("Everyone at my campus"),
    @SerialName("memberOnly")   MEMBER_ONLY("Members of my club"),
    @SerialName("officersOnly") OFFICERS_ONLY("Board only"),
    @SerialName("inviteOnly")   INVITE_ONLY("Invite only")
}

enum class EventUrgency(val label: String, val color: Color) {
    LIVE("LIVE", Color(0xFFFF3B30)),
    STARTING("STARTING", Color(0xFFFF9F0A)),
    SOON("SOON", Color(0xFFC850FF)),
    UPCOMING("UPCOMING", Color(0xFF8E8E93)),
    PAST("PAST", Color(0xFF48484A))
}

@Serializable
enum class RSVPStatus {
    @SerialName("notGoing")   NOT_GOING,
    @SerialName("interested") INTERESTED,
    @SerialName("going")      GOING
}

enum class TimeFilter(val label: String) {
    NOW("Now"), TONIGHT("Tonight"), TOMORROW("Tomorrow"), WEEK("This Week");

    fun matches(event: Event, nowEpochSec: Long = Instant.now().epochSecond): Boolean {
        val today = LocalDate.now(ZoneId.systemDefault())
        val startDate = Instant.ofEpochSecond(event.startsAtEpochSec).atZone(ZoneId.systemDefault()).toLocalDate()
        val endDate = Instant.ofEpochSecond(event.endsAtEpochSec).atZone(ZoneId.systemDefault()).toLocalDate()
        return when (this) {
            NOW -> nowEpochSec in (event.startsAtEpochSec - 30 * 60)..event.endsAtEpochSec
            TONIGHT -> startDate == today || endDate == today
            TOMORROW -> startDate == today.plusDays(1)
            WEEK -> event.startsAtEpochSec in nowEpochSec..(nowEpochSec + 7 * 24 * 3600)
        }
    }
}
