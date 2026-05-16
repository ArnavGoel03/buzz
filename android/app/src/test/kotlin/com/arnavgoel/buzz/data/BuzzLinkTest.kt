package com.arnavgoel.buzz.data

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.UUID

/// Parity tests with iOS `BuzzLinkTests`. Same path scheme on both platforms; a
/// regression on either side breaks shared deep links shipped via App Clip → Android
/// share / vice-versa.
class BuzzLinkTest {

    @Test
    fun `validate event URL returns Event kind with parsed UUID`() {
        val id = UUID.randomUUID()
        val kind = BuzzLink.validate("https://buzz.app/e/${id}")
        assertTrue(kind is BuzzLink.Kind.Event)
        assertEquals(id, (kind as BuzzLink.Kind.Event).id)
    }

    @Test
    fun `validate organization URL returns Organization kind`() {
        val kind = BuzzLink.validate("https://buzz.app/o/sigma-phi")
        assertEquals(BuzzLink.Kind.Organization("sigma-phi"), kind)
    }

    @Test
    fun `validate profile URL returns Profile kind`() {
        val kind = BuzzLink.validate("https://buzz.app/u/alex")
        assertEquals(BuzzLink.Kind.Profile("alex"), kind)
    }

    @Test
    fun `validate rejects lookalike host`() {
        // VULN #58 — phishing prevention. Treat lookalike-but-not-buzz hosts as junk.
        assertNull(BuzzLink.validate("https://buzz.app.evil.example/e/${UUID.randomUUID()}"))
    }

    @Test
    fun `validate rejects HTTP scheme`() {
        assertNull(BuzzLink.validate("http://buzz.app/e/${UUID.randomUUID()}"))
    }

    @Test
    fun `validate rejects unknown path prefix`() {
        assertNull(BuzzLink.validate("https://buzz.app/admin/${UUID.randomUUID()}"))
    }

    @Test
    fun `validate rejects extra path components`() {
        assertNull(BuzzLink.validate("https://buzz.app/e/${UUID.randomUUID()}/extra"))
    }

    @Test
    fun `validate rejects bare host`() {
        assertNull(BuzzLink.validate("https://buzz.app/"))
    }

    @Test
    fun `validate rejects malformed UUID on event path`() {
        assertNull(BuzzLink.validate("https://buzz.app/e/not-a-uuid"))
    }

    @Test
    fun `validate rejects malformed URL`() {
        assertNull(BuzzLink.validate("not even a url"))
    }
}
