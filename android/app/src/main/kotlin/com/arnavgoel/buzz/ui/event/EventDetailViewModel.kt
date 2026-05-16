package com.arnavgoel.buzz.ui.event

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arnavgoel.buzz.data.AppServices
import com.arnavgoel.buzz.data.model.Event
import com.arnavgoel.buzz.data.model.Profile
import com.arnavgoel.buzz.data.model.RSVPStatus
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class EventDetailState(
    val event: Event? = null,
    val friendsGoing: List<Profile> = emptyList(),
    val myRsvp: RSVPStatus = RSVPStatus.NOT_GOING,
    val loading: Boolean = true,
    val error: String? = null
)

class EventDetailViewModel(
    private val services: AppServices = AppServices.shared()
) : ViewModel() {
    private val _state = MutableStateFlow(EventDetailState())
    val state: StateFlow<EventDetailState> = _state.asStateFlow()

    fun load(eventId: String) {
        viewModelScope.launch {
            _state.value = EventDetailState(loading = true)
            try {
                val event = services.events.event(eventId)
                val friends = services.events.friendsGoing(eventId)
                val mine = services.events.myRsvps()[eventId] ?: RSVPStatus.NOT_GOING
                _state.value = EventDetailState(
                    event = event,
                    friendsGoing = friends,
                    myRsvp = mine,
                    loading = false,
                    error = if (event == null) "Event not found." else null
                )
            } catch (t: Throwable) {
                _state.value = EventDetailState(loading = false, error = t.message)
            }
        }
    }

    fun setRsvp(status: RSVPStatus) {
        val eventId = _state.value.event?.id ?: return
        val previous = _state.value.myRsvp
        // Optimistic — matches iOS UX. Roll back on failure so the UI doesn't show a
        // state the server never accepted.
        _state.value = _state.value.copy(myRsvp = status)
        viewModelScope.launch {
            runCatching { services.events.rsvp(eventId, status) }
                .onFailure {
                    _state.value = _state.value.copy(
                        myRsvp = previous,
                        error = "Couldn't save your RSVP. Try again."
                    )
                }
        }
    }
}
