package com.arnavgoel.buzz.ui.safety

import android.content.Intent
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import kotlinx.coroutines.delay

/**
 * 3-second hold to trigger emergency SOS — mirrors iOS `EmergencySOSButton`'s hold gesture
 * so muscle memory transfers between platforms.
 *
 * On hold-complete: opens the system dialer with the local emergency number. Later phases
 * also: write an `sos_events` row to Supabase, notify the user's emergency contact, and
 * surface a "Cancel SOS" countdown for accidental triggers.
 */
@Composable
fun EmergencySosButton() {
    val ctx = LocalContext.current
    var holdProgress by remember { mutableFloatStateOf(0f) }
    var pressed by remember { mutableStateOf(false) }
    val targetMillis = 3_000L

    LaunchedEffect(pressed) {
        if (pressed) {
            val start = System.currentTimeMillis()
            while (pressed) {
                val elapsed = System.currentTimeMillis() - start
                holdProgress = (elapsed.toFloat() / targetMillis).coerceAtMost(1f)
                if (elapsed >= targetMillis) {
                    pressed = false
                    ctx.startActivity(Intent(Intent.ACTION_DIAL, "tel:911".toUri()))
                }
                delay(50)
            }
            holdProgress = 0f
        }
    }

    Box(
        modifier = Modifier
            .padding(20.dp)
            .size(76.dp)
            .background(MaterialTheme.colorScheme.error, CircleShape)
            .semantics { contentDescription = "Emergency SOS. Hold 3 seconds to call 911." }
            .pointerInput(Unit) {
                detectTapGestures(onPress = {
                    pressed = true; tryAwaitRelease(); pressed = false
                })
            },
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = if (holdProgress > 0f) "${(holdProgress * 3).toInt() + 1}…" else "SOS",
            style = MaterialTheme.typography.titleLarge,
            color = Color.White
        )
    }
}
