package com.arnavgoel.buzz.data

import java.util.UUID

/// Universal-link parser. Mirrors the iOS `BuzzLink.validate(_:)` contract — same
/// host, same path scheme. **Keep both ports in sync** so a regression on one
/// platform surfaces in shared end-to-end tests.
///
/// Path scheme:
///   https://buzz.app/e/{uuid}   → event
///   https://buzz.app/o/{handle} → organization
///   https://buzz.app/u/{handle} → profile
object BuzzLink {
    const val HOST = "buzz.app"

    sealed class Kind {
        data class Event(val id: UUID) : Kind()
        data class Organization(val handle: String) : Kind()
        data class Profile(val handle: String) : Kind()
    }

    /// Returns the matched `Kind` or `null` if the URL doesn't belong to Buzz, isn't
    /// HTTPS, or has an unknown path. Callers MUST treat `null` as "drop the deep link"
    /// — never fall back to opening an arbitrary URL in-app, that's a phishing vector.
    private val HANDLE_RE = Regex("^[A-Za-z0-9_\\-]{1,40}$")

    fun validate(url: String): Kind? {
        val parsed = runCatching { java.net.URI(url) }.getOrNull() ?: return null
        if (parsed.scheme != "https") return null
        if (parsed.host != HOST) return null
        val parts = parsed.path.split("/").filter { it.isNotEmpty() }
        if (parts.size != 2) return null
        return when (parts[0]) {
            "e" -> runCatching { UUID.fromString(parts[1]) }.getOrNull()?.let(Kind::Event)
            // Reject anything outside the canonical handle shape — protects nav-route
            // injection and path-traversal via percent-encoded `/` or NUL bytes.
            "o" -> if (HANDLE_RE.matches(parts[1])) Kind.Organization(parts[1]) else null
            "u" -> if (HANDLE_RE.matches(parts[1])) Kind.Profile(parts[1]) else null
            else -> null
        }
    }
}
