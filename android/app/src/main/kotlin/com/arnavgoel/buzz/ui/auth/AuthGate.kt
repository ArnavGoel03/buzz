package com.arnavgoel.buzz.ui.auth

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.*
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.*
import com.arnavgoel.buzz.data.Buzz
import io.github.jan.supabase.auth.*
import io.github.jan.supabase.auth.providers.builtin.Email
import kotlinx.coroutines.launch

/**
 * Auth gate. Until Supabase reports an authenticated session we render the sign-in
 * screen. No-op when Supabase isn't configured (mock builds), so previews still run.
 */
@Composable
fun AuthGate(content: @Composable () -> Unit) {
    // Mock builds (no Supabase configured) pass through in debug only — release builds
    // without Supabase must still force sign-in, never silently grant access.
    val client = remember { runCatching { Buzz.supabase }.getOrNull() }
    if (client == null) {
        if (com.arnavgoel.buzz.BuildConfig.DEBUG) { content() } else { SignInScreen() }
        return
    }

    val status by client.auth.sessionStatus.collectAsState()
    when (status) {
        is SessionStatus.Authenticated -> content()
        else -> SignInScreen()
    }
}

@Composable
private fun SignInScreen() {
    var email by remember { mutableStateOf("") }
    var sending by remember { mutableStateOf(false) }
    var sent by remember { mutableStateOf(false) }
    var error by remember { mutableStateOf<String?>(null) }
    val scope = rememberCoroutineScope()

    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("Buzz", style = MaterialTheme.typography.displayLarge,
            color = MaterialTheme.colorScheme.onBackground)
        Spacer(Modifier.height(8.dp))
        Text("Your campus, live.", style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(Modifier.height(40.dp))

        if (sent) {
            Text("Check your inbox for a magic link.",
                textAlign = TextAlign.Center,
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onSurface)
        } else {
            OutlinedTextField(
                value = email,
                onValueChange = { email = it; error = null },
                placeholder = { Text("you@school.edu") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            error?.let {
                Spacer(Modifier.height(8.dp))
                Text(it, style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.error)
            }
            Spacer(Modifier.height(16.dp))
            Button(
                onClick = {
                    if (email.isBlank()) { error = "Enter your email."; return@Button }
                    sending = true
                    scope.launch {
                        runCatching {
                            Buzz.supabase.auth.signInWith(Email) { this.email = email }
                        }.onSuccess { sent = true }
                            .onFailure { error = it.message ?: "Couldn't send the magic link." }
                        sending = false
                    }
                },
                enabled = !sending,
                modifier = Modifier.fillMaxWidth()
            ) { Text(if (sending) "Sending…" else "Send magic link") }
        }
    }
}
