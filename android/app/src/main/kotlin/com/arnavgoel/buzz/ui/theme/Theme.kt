package com.arnavgoel.buzz.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

// iOS app is dark-only; Android matches by defaulting to dark and providing a light
// palette only as a Material 3 hygiene fallback. Dynamic color is opt-in (off by default
// to keep the brand purple/pink on Android 12+ devices).
private val DarkColors = darkColorScheme(
    primary = BuzzPurple,
    onPrimary = BuzzTextPrimary,
    primaryContainer = BuzzAccentDim,
    onPrimaryContainer = BuzzTextPrimary,
    secondary = BuzzPink,
    onSecondary = BuzzTextPrimary,
    background = BuzzBackground,
    onBackground = BuzzTextPrimary,
    surface = BuzzSurface,
    onSurface = BuzzTextPrimary,
    surfaceVariant = BuzzSurfaceElevated,
    onSurfaceVariant = BuzzTextSecondary,
    error = BuzzLive,
    onError = BuzzTextPrimary
)

private val LightColors = lightColorScheme(
    primary = BuzzPurple,
    secondary = BuzzPink,
    error = BuzzLive
)

@Composable
fun BuzzTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    val colors = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val ctx = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(ctx) else dynamicLightColorScheme(ctx)
        }
        darkTheme -> DarkColors
        else -> LightColors
    }
    MaterialTheme(
        colorScheme = colors,
        typography = BuzzTypography,
        content = content
    )
}
