package com.arnavgoel.buzz.ui.clubs

import android.content.Intent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import com.arnavgoel.buzz.data.AppServices
import com.arnavgoel.buzz.data.model.Organization

@Composable
fun OrganizationScreen(handle: String, onClose: () -> Unit) {
    var org by remember { mutableStateOf<Organization?>(null) }
    var loading by remember { mutableStateOf(true) }
    LaunchedEffect(handle) {
        org = AppServices.shared().orgs.organization(handle.trimStart('@'))
        loading = false
    }
    val ctx = LocalContext.current
    Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        when {
            loading -> Text("Loading…", modifier = Modifier.padding(24.dp),
                color = MaterialTheme.colorScheme.onSurfaceVariant)
            org == null -> Column(Modifier.padding(24.dp)) {
                Text("Club not found.", color = MaterialTheme.colorScheme.onSurface)
                OutlinedButton(onClick = onClose, modifier = Modifier.padding(top = 16.dp)) {
                    Text("Back")
                }
            }
            else -> LazyColumn(
                contentPadding = PaddingValues(20.dp, 24.dp, 20.dp, 96.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                val o = org!!
                item {
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Text(o.category.displayName.uppercase(),
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.primary)
                        Text(o.name, style = MaterialTheme.typography.displaySmall,
                            color = MaterialTheme.colorScheme.onBackground)
                        if (o.tagline.isNotBlank()) Text(o.tagline,
                            style = MaterialTheme.typography.titleMedium,
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
                        Text("${o.memberCount} members" +
                            (if (o.isVerified) " · verified" else "") +
                            (o.foundedYear?.let { " · founded $it" } ?: ""),
                            style = MaterialTheme.typography.labelMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                        if (o.description.isNotBlank()) Text(o.description,
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurface)
                    }
                }
                item {
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        Button(onClick = { /* TODO follow */ }) { Text("Follow") }
                        o.safeInstagramUrl?.let { url ->
                            OutlinedButton(onClick = {
                                ctx.startActivity(Intent(Intent.ACTION_VIEW, url.toUri()))
                            }) { Text("Instagram") }
                        }
                        o.safeWebsiteUrl?.let { url ->
                            OutlinedButton(onClick = {
                                ctx.startActivity(Intent(Intent.ACTION_VIEW, url.toUri()))
                            }) { Text("Website") }
                        }
                    }
                }
            }
        }
    }
}
