package com.arnavgoel.buzz.ui.settings

import android.content.Intent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import com.arnavgoel.buzz.BuildConfig

@Composable
fun SettingsScreen(onSignOut: () -> Unit) {
    var freeFood by remember { mutableStateOf(true) }
    var friendActivity by remember { mutableStateOf(true) }
    var weeklyDigest by remember { mutableStateOf(true) }
    val ctx = LocalContext.current

    fun openUrl(url: String) = ctx.startActivity(Intent(Intent.ACTION_VIEW, url.toUri()))

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 24.dp, bottom = 96.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            Text("Settings", style = MaterialTheme.typography.displaySmall,
                color = MaterialTheme.colorScheme.onBackground)
        }
        item { ToggleRow("Free-food alerts", freeFood) { freeFood = it } }
        item { ToggleRow("Friend activity", friendActivity) { friendActivity = it } }
        item { ToggleRow("Weekly digest", weeklyDigest) { weeklyDigest = it } }
        item { HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant) }
        item { TextButton(onClick = { openUrl("https://buzz.app/legal/privacy") }) { Text("Privacy policy") } }
        item { TextButton(onClick = { openUrl("https://buzz.app/legal/terms") }) { Text("Terms of service") } }
        item { TextButton(onClick = { openUrl("mailto:hi@buzz.app") }) { Text("Send feedback") } }
        item { HorizontalDivider(color = MaterialTheme.colorScheme.surfaceVariant) }
        item {
            OutlinedButton(onClick = onSignOut, modifier = Modifier.fillMaxWidth()) {
                Text("Sign out")
            }
        }
        item {
            // Play Store policy: prominent in-app account deletion (parity with iOS).
            TextButton(onClick = { openUrl("https://buzz.app/settings#delete") },
                modifier = Modifier.fillMaxWidth()) { Text("Delete account") }
        }
        item {
            Text("Buzz v${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(top = 24.dp))
        }
    }
}

@Composable
private fun ToggleRow(label: String, value: Boolean, onChange: (Boolean) -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(label, style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurface)
        Switch(checked = value, onCheckedChange = onChange)
    }
}
