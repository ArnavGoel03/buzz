package com.arnavgoel.buzz.ui.clubs

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arnavgoel.buzz.data.AppServices
import com.arnavgoel.buzz.data.model.Organization
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class ClubsState(
    val results: List<Organization> = emptyList(),
    val query: String = "",
    val loading: Boolean = false
)

class ClubsViewModel(
    private val services: AppServices = AppServices.shared()
) : ViewModel() {
    private val _state = MutableStateFlow(ClubsState(loading = true))
    val state: StateFlow<ClubsState> = _state.asStateFlow()
    private var searchJob: Job? = null

    init {
        viewModelScope.launch {
            val trending = services.orgs.trending(campus = "ucsd")
            _state.value = ClubsState(results = trending)
        }
    }

    fun search(q: String) {
        _state.value = _state.value.copy(query = q)
        searchJob?.cancel()
        searchJob = viewModelScope.launch {
            // 250ms debounce — mirrors iOS `PeopleSearchSheet` debounce so we don't hammer
            // Postgrest on every keystroke.
            delay(250)
            val results = if (q.isBlank()) services.orgs.trending("ucsd")
            else services.orgs.search(q, "ucsd")
            _state.value = _state.value.copy(results = results)
        }
    }
}
