package com.arnavgoel.buzz.ui.feed

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import com.arnavgoel.buzz.ui.theme.BuzzTheme
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test

/// Compose UI smoke tests for the placeholder feed. Catches regressions where:
///   - the brand wordmark stops rendering
///   - the placeholder events disappear (someone breaks the feed list)
///   - tapping a card no longer fires the onEventTap callback (broken navigation)
class FeedScreenTest {

    @get:Rule
    val composeRule = createComposeRule()

    @Test
    fun feedScreen_rendersWordmarkAndAtLeastOneEvent() {
        composeRule.setContent { BuzzTheme { FeedScreen(onEventTap = {}) } }
        composeRule.onNodeWithText("Buzz").assertIsDisplayed()
        composeRule.onNodeWithText("AI x Founders Mixer").assertIsDisplayed()
    }

    @Test
    fun feedScreen_eventTap_fires_onEventTap_with_event_id() {
        var tappedId: String? = null
        composeRule.setContent {
            BuzzTheme {
                FeedScreen(onEventTap = { id -> tappedId = id })
            }
        }
        composeRule.onNodeWithText("AI x Founders Mixer").performClick()
        assertEquals("1", tappedId)
    }
}
