package com.arnavgoel.buzz.ui.event

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.arnavgoel.buzz.data.model.RSVPStatus
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

@Composable
fun EventDetailScreen(
    eventId: String,
    onClose: () -> Unit,
    vm: EventDetailViewModel = viewModel()
) {
    val state by vm.state.collectAsState()
    LaunchedEffect(eventId) { vm.load(eventId) }

    Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        when {
            state.loading -> Text("Loading…", modifier = Modifier.padding(24.dp),
                color = MaterialTheme.colorScheme.onSurfaceVariant)
            state.event == null -> Column(Modifier.padding(24.dp)) {
                Text(state.error ?: "Event not found.", color = MaterialTheme.colorScheme.onSurface)
                Spacer(Modifier.height(16.dp))
                OutlinedButton(onClick = onClose) { Text("Back") }
            }
            else -> {
                val event = state.event!!
                val fmt = DateTimeFormatter.ofPattern("EEE, MMM d · h:mm a").withZone(ZoneId.systemDefault())
                LazyColumn(
                    contentPadding = PaddingValues(20.dp, 24.dp, 20.dp, 120.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    item {
                        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            Text(event.category.shortName.uppercase(),
                                style = MaterialTheme.typography.labelSmall,
                                color = event.category.tint)
                            Text(event.title, style = MaterialTheme.typography.displaySmall,
                                color = MaterialTheme.colorScheme.onBackground)
                            Text(fmt.format(Instant.ofEpochSecond(event.startsAtEpochSec)),
                                style = MaterialTheme.typography.titleMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant)
                            Text(event.location.name + (event.location.address?.let { " · $it" } ?: ""),
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                    item {
                        Column(
                            modifier = Modifier.fillMaxWidth()
                                .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(16.dp))
                                .padding(20.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Text("Hosted by ${event.hostName}",
                                style = MaterialTheme.typography.labelMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant)
                            if (event.summary.isNotBlank()) {
                                Text(event.summary, style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurface)
                            }
                        }
                    }
                    item { RsvpRow(state.myRsvp, vm::setRsvp) }
                    if (state.friendsGoing.isNotEmpty() && !event.hideAttendees) {
                        item {
                            Text("Friends going: " + state.friendsGoing.joinToString { it.displayName },
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                    item {
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            event.tags.forEach { tag ->
                                Text("#$tag", style = MaterialTheme.typography.labelMedium,
                                    color = MaterialTheme.colorScheme.primary)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun RsvpRow(current: RSVPStatus, onPick: (RSVPStatus) -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        Button(
            onClick = { onPick(RSVPStatus.GOING) },
            colors = ButtonDefaults.buttonColors(
                containerColor = if (current == RSVPStatus.GOING)
                    MaterialTheme.colorScheme.primary
                else MaterialTheme.colorScheme.surfaceVariant,
                contentColor = MaterialTheme.colorScheme.onPrimary
            ),
            modifier = Modifier.fillMaxWidth(0.5f)
        ) { Text("Going") }
        OutlinedButton(onClick = { onPick(RSVPStatus.INTERESTED) }, modifier = Modifier.fillMaxWidth()) {
            Text(if (current == RSVPStatus.INTERESTED) "Interested ✓" else "Interested")
        }
    }
}
