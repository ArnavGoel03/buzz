package com.arnavgoel.buzz.ui.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.arnavgoel.buzz.data.AppServices
import com.arnavgoel.buzz.data.model.Profile

@Composable
fun ProfileScreen(onOpenSettings: () -> Unit) {
    var profile by remember { mutableStateOf<Profile?>(null) }
    LaunchedEffect(Unit) { profile = AppServices.shared().profiles.me() }
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 24.dp, bottom = 96.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            val p = profile
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Box(
                    modifier = Modifier.size(96.dp)
                        .background(p?.let { hexColor(it.accentHex) } ?: MaterialTheme.colorScheme.primary,
                            CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Text(p?.initials ?: "?", style = MaterialTheme.typography.displaySmall,
                        color = MaterialTheme.colorScheme.onPrimary)
                }
                Text(p?.displayName ?: "Sign in to see your profile",
                    style = MaterialTheme.typography.displaySmall,
                    color = MaterialTheme.colorScheme.onBackground)
                Text(p?.displayHandle ?: "@", style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant)
                p?.bio?.takeIf { it.isNotBlank() }?.let {
                    Text(it, style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurface)
                }
            }
        }
        item {
            Column(
                modifier = Modifier.fillMaxWidth()
                    .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(16.dp))
                    .padding(16.dp)
            ) {
                Text("Streak", style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant)
                Text("0 weeks", style = MaterialTheme.typography.titleLarge,
                    color = MaterialTheme.colorScheme.onSurface)
                Text("Attend an event this week to start a streak.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
        item {
            OutlinedButton(onClick = onOpenSettings, modifier = Modifier.fillMaxWidth()) {
                Text("Settings")
            }
            Spacer(Modifier.height(8.dp))
        }
    }
}

private fun hexColor(hex: String): Color {
    val cleaned = hex.removePrefix("#")
    return runCatching {
        val v = cleaned.toLong(radix = 16)
        Color(
            red = ((v shr 16) and 0xFF) / 255f,
            green = ((v shr 8) and 0xFF) / 255f,
            blue = (v and 0xFF) / 255f
        )
    }.getOrDefault(Color(0xFFC850FF))
}
