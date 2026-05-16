package com.arnavgoel.buzz.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class Profile(
    val id: String,
    @SerialName("display_name") val displayName: String,
    val handle: String,
    val pronouns: String? = null,
    val bio: String? = null,
    @SerialName("avatar_url") val avatarUrl: String? = null,
    @SerialName("accent_hex") val accentHex: String = "#C850FF"
) {
    /** Mirrors iOS `Profile.displayHandle` (VULN #81 / #91 patches): never render bare "@". */
    val displayHandle: String
        get() {
            val bare = handle.dropWhile { it == '@' }.trim()
            if (bare.isEmpty()) {
                val slug = displayName.lowercase().filter { it.isLetterOrDigit() }
                return "@$slug"
            }
            return "@$bare"
        }

    val initials: String
        get() = displayName
            .split(" ")
            .take(2)
            .mapNotNull { it.firstOrNull()?.toString() }
            .joinToString("")
            .uppercase()
}
