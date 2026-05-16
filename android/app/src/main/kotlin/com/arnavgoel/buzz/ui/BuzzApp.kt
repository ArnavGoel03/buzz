package com.arnavgoel.buzz.ui

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.arnavgoel.buzz.ui.feed.FeedScreen
import com.arnavgoel.buzz.ui.theme.BuzzTheme

@Composable
fun BuzzApp() {
    BuzzTheme {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colorScheme.background
        ) {
            val navController = rememberNavController()
            NavHost(
                navController = navController,
                startDestination = "feed"
            ) {
                composable("feed") {
                    FeedScreen(onEventTap = { id ->
                        navController.navigate("event/$id")
                    })
                }
                composable("event/{id}") { backStackEntry ->
                    val id = backStackEntry.arguments?.getString("id").orEmpty()
                    // Placeholder — wire up EventDetailScreen later.
                    FeedScreen(onEventTap = { _ -> })
                }
            }
        }
    }
}
