package com.arnavgoel.buzz.ui.feed

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.arnavgoel.buzz.data.model.Event
import kotlinx.coroutines.delay
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

@Composable
fun EventCard(event: Event, onClick: () -> Unit) {
    // Refresh urgency every 30s so LIVE/STARTING transitions feel real-time without burning battery.
    var nowSec by remember { mutableLongStateOf(Instant.now().epochSecond) }
    LaunchedEffect(event.id) {
        while (true) { delay(30_000); nowSec = Instant.now().epochSecond }
    }
    val urgency = event.urgencyAt(nowSec)

    Card(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .semantics { contentDescription = "${event.title}, ${event.location.name}, ${urgency.label}" },
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        shape = RoundedCornerShape(18.dp)
    ) {
        Column {
            // 2px urgency stripe — visual parity with iOS `EventCard`'s time-density bar.
            Box(Modifier.fillMaxWidth().height(2.dp).background(urgency.color))
            Column(
                modifier = Modifier.fillMaxWidth().padding(20.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(urgency.label, style = MaterialTheme.typography.labelSmall, color = urgency.color)
                    Text(formatStart(event.startsAtEpochSec, nowSec).uppercase(),
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text(event.category.shortName.uppercase(),
                        style = MaterialTheme.typography.labelSmall, color = event.category.tint)
                }
                Text(event.title, style = MaterialTheme.typography.headlineSmall,
                    color = MaterialTheme.colorScheme.onSurface)
                Text(event.location.name, style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant)
                if (event.rsvpCount > 0 && !event.hideAttendees) {
                    Text("${event.rsvpCount} going", style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }
    }
}

private val timeFmt = DateTimeFormatter.ofPattern("EEE, h:mm a").withZone(ZoneId.systemDefault())

private fun formatStart(startSec: Long, nowSec: Long): String {
    val delta = startSec - nowSec
    if (delta in 0..3599) return "in ${delta / 60} min"
    if (delta in -3599..-1) return "started ${-delta / 60}m ago"
    return timeFmt.format(Instant.ofEpochSecond(startSec))
}
