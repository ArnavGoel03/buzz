package com.arnavgoel.buzz.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class Organization(
    val id: String,
    val name: String,
    val handle: String,
    val tagline: String = "",
    val description: String = "",
    val category: OrganizationCategory = OrganizationCategory.GENERAL,
    val campus: String,
    @SerialName("founded_year") val foundedYear: Int? = null,
    @SerialName("member_count") val memberCount: Int = 0,
    @SerialName("logo_url") val logoUrl: String? = null,
    @SerialName("cover_url") val coverUrl: String? = null,
    @SerialName("accent_hex") val accentHex: String = "#C850FF",
    @SerialName("is_verified") val isVerified: Boolean = false,
    @SerialName("instagram_handle") val instagramHandle: String? = null,
    @SerialName("website_url") val websiteUrl: String? = null
) {
    /**
     * Mirrors iOS `Organization.instagramURL`. Only accepts the Instagram-allowed
     * character set (alphanumerics + . + _) so a raw user-entered "insta.sketchy/login"
     * style value can't sneak through into a tappable link.
     */
    val safeInstagramUrl: String?
        get() {
            val raw = instagramHandle?.trim().orEmpty()
            if (raw.isEmpty()) return null
            val cleaned = if (raw.startsWith("@")) raw.drop(1) else raw
            if (cleaned.isEmpty()) return null
            val allowed = cleaned.all { it.isLetterOrDigit() || it == '.' || it == '_' }
            return if (allowed) "https://instagram.com/$cleaned" else null
        }

    /** Mirrors iOS `safeWebsiteURL` — only http/https survive. */
    val safeWebsiteUrl: String?
        get() {
            val url = websiteUrl ?: return null
            val lower = url.lowercase()
            return if (lower.startsWith("https://") || lower.startsWith("http://")) url else null
        }
}

@Serializable
enum class OrganizationCategory(val displayName: String) {
    @SerialName("greek")        GREEK("Greek life"),
    @SerialName("academic")     ACADEMIC("Academic"),
    @SerialName("cultural")     CULTURAL("Cultural"),
    @SerialName("religious")    RELIGIOUS("Religious"),
    @SerialName("sports")       SPORTS("Sports"),
    @SerialName("arts")         ARTS("Arts"),
    @SerialName("service")      SERVICE("Service"),
    @SerialName("professional") PROFESSIONAL("Professional"),
    @SerialName("political")    POLITICAL("Political"),
    @SerialName("identity")     IDENTITY("Identity"),
    @SerialName("general")      GENERAL("General")
}
