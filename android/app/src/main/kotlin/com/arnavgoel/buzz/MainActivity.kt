package com.arnavgoel.buzz

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.arnavgoel.buzz.data.BuzzLink
import com.arnavgoel.buzz.ui.AppNav
import com.arnavgoel.buzz.ui.BuzzApp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent { BuzzApp() }
        handleDeepLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleDeepLink(intent)
    }

    /**
     * Route a `https://buzz.app/...` intent through the shared validator so we never
     * navigate to a non-Buzz host. Falls back to no-op for unrecognised URLs — the
     * activity remains on whatever screen the user was on (or the start destination).
     */
    private fun handleDeepLink(intent: Intent?) {
        val data = intent?.data?.toString() ?: return
        val kind = BuzzLink.validate(data) ?: return
        val nav = AppNav.controller ?: return
        when (kind) {
            is BuzzLink.Kind.Event -> nav.navigate("event/${kind.id}")
            is BuzzLink.Kind.Organization -> nav.navigate("org/${kind.handle}")
            is BuzzLink.Kind.Profile -> nav.navigate("profile") // own profile only; public profile route TBD
        }
    }
}
