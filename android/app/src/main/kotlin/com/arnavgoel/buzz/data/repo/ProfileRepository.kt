package com.arnavgoel.buzz.data.repo

import com.arnavgoel.buzz.data.model.Profile

interface ProfileRepository {
    suspend fun me(): Profile?
    suspend fun profile(handle: String): Profile?
}

class MockProfileRepository : ProfileRepository {
    private val me = Profile(
        id = "me",
        displayName = "Arnav Goel",
        handle = "arnav",
        pronouns = "he/him",
        bio = "Building Buzz · UCSD",
        accentHex = "#C850FF"
    )
    override suspend fun me() = me
    override suspend fun profile(handle: String): Profile? =
        if (handle.trimStart('@') == me.handle) me else null
}
