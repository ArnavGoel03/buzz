package com.arnavgoel.buzz.ui.map

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.arnavgoel.buzz.ui.feed.EventCard
import com.arnavgoel.buzz.ui.feed.LiveFeedViewModel

/**
 * Placeholder Map tab. Renders the live events as a sorted list while we wire up
 * Google Maps Compose or MapLibre. Tap an event to deep-link to detail, matching the
 * iOS MapView interaction model.
 */
@Composable
fun MapScreen(
    onEventTap: (String) -> Unit,
    vm: LiveFeedViewModel = viewModel()
) {
    val state by vm.state.collectAsState()
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 24.dp, bottom = 96.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Map", style = MaterialTheme.typography.displayMedium,
                    color = MaterialTheme.colorScheme.onBackground)
                Text("Pinning live events near you. (Native map coming next.)",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
        items(state.events, key = { it.id }) { event ->
            EventCard(event = event, onClick = { onEventTap(event.id) })
        }
    }
}
