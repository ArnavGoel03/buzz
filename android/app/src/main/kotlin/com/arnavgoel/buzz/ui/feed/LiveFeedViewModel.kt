package com.arnavgoel.buzz.ui.feed

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arnavgoel.buzz.data.AppServices
import com.arnavgoel.buzz.data.model.Event
import com.arnavgoel.buzz.data.model.EventCategory
import com.arnavgoel.buzz.data.model.TimeFilter
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.time.Instant

data class LiveFeedState(
    val events: List<Event> = emptyList(),
    val timeFilter: TimeFilter = TimeFilter.NOW,
    val categoryFilter: EventCategory? = null,
    val loading: Boolean = false,
    val error: String? = null
)

class LiveFeedViewModel(
    private val services: AppServices = AppServices.shared()
) : ViewModel() {
    private val _state = MutableStateFlow(LiveFeedState(loading = true))
    val state: StateFlow<LiveFeedState> = _state.asStateFlow()

    init { reload() }

    fun reload() {
        viewModelScope.launch {
            _state.value = _state.value.copy(loading = true, error = null)
            try {
                val events = services.events.eventsNear(32.8801, -117.2340, 2000.0)
                _state.value = _state.value.copy(events = events, loading = false)
            } catch (t: Throwable) {
                _state.value = _state.value.copy(
                    loading = false,
                    error = t.message ?: "Couldn't load events"
                )
            }
        }
    }

    fun setTimeFilter(f: TimeFilter) {
        _state.value = _state.value.copy(timeFilter = f)
    }

    fun setCategory(c: EventCategory?) {
        _state.value = _state.value.copy(categoryFilter = c)
    }

    val visibleEvents: List<Event>
        get() {
            val s = _state.value
            val now = Instant.now().epochSecond
            return s.events
                .filter { s.timeFilter.matches(it, now) }
                .filter { s.categoryFilter == null || it.category == s.categoryFilter }
        }
}
