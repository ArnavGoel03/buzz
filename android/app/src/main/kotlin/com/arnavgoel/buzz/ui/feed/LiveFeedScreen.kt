package com.arnavgoel.buzz.ui.feed

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.arnavgoel.buzz.data.model.TimeFilter

@Composable
fun LiveFeedScreen(
    onEventTap: (String) -> Unit,
    vm: LiveFeedViewModel = viewModel()
) {
    val state by vm.state.collectAsState()
    val visible = vm.visibleEvents

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 24.dp, bottom = 96.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                val liveCount = visible.count { it.isLiveAt(java.time.Instant.now().epochSecond) }
                Text("TONIGHT · $liveCount LIVE", style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant)
                Text("Live Now", style = MaterialTheme.typography.displayMedium,
                    color = MaterialTheme.colorScheme.onBackground)
                Text("Happening within a 10-minute walk.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(top = 4.dp))
            }
        }
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                TimeFilter.entries.forEach { f ->
                    FilterChip(
                        selected = state.timeFilter == f,
                        onClick = { vm.setTimeFilter(f) },
                        label = { Text(f.label) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = MaterialTheme.colorScheme.primary,
                            selectedLabelColor = MaterialTheme.colorScheme.onPrimary
                        )
                    )
                }
            }
        }
        if (state.loading && visible.isEmpty()) {
            item { Text("Loading…", style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant) }
        } else if (visible.isEmpty()) {
            item {
                Text(state.error ?: "Nothing matching that filter right now. Check back in a bit.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
        items(visible, key = { it.id }) { event ->
            EventCard(event = event, onClick = { onEventTap(event.id) })
        }
    }
}
