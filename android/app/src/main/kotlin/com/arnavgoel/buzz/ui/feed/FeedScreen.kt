package com.arnavgoel.buzz.ui.feed

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

private data class PlaceholderEvent(
    val id: String,
    val title: String,
    val time: String,
    val venue: String
)

private val placeholders = listOf(
    PlaceholderEvent("1", "AI x Founders Mixer", "Tonight · 8:00 PM", "Geisel Library"),
    PlaceholderEvent("2", "Sigma Phi Rush Week — Day 3", "Tonight · 9:30 PM", "Greek Row"),
    PlaceholderEvent("3", "Free Pizza @ Career Center", "Tomorrow · 12:00 PM", "Career Center")
)

@Composable
fun FeedScreen(onEventTap: (String) -> Unit) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(24.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item { Header() }
        items(placeholders, key = { it.id }) { event ->
            EventCard(
                title = event.title,
                time = event.time,
                venue = event.venue,
                onClick = { onEventTap(event.id) }
            )
        }
    }
}

@Composable
private fun Header() {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(
            text = "TONIGHT · 3 LIVE · 10 MIN WALK",
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = "Buzz",
            style = MaterialTheme.typography.displayLarge,
            color = MaterialTheme.colorScheme.onBackground
        )
        Text(
            text = "Events at your campus, on one map. Android scaffold — coming soon.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(top = 4.dp)
        )
    }
}
