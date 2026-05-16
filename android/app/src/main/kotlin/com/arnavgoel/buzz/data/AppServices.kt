package com.arnavgoel.buzz.data

import com.arnavgoel.buzz.BuildConfig
import com.arnavgoel.buzz.data.repo.EventsRepository
import com.arnavgoel.buzz.data.repo.MockEventsRepository
import com.arnavgoel.buzz.data.repo.MockOrganizationsRepository
import com.arnavgoel.buzz.data.repo.MockProfileRepository
import com.arnavgoel.buzz.data.repo.OrganizationsRepository
import com.arnavgoel.buzz.data.repo.ProfileRepository
import com.arnavgoel.buzz.data.repo.SupabaseEventsRepository

/**
 * Tiny service-locator (mirrors iOS `AppServices`). Single instance owned by
 * [com.arnavgoel.buzz.BuzzApplication]; ViewModels accept the bundle via constructor or
 * read from the application class. Repository choice is driven by whether Supabase is
 * actually configured in `local.properties` — when credentials are missing the app boots
 * cleanly against the mock seed instead of throwing on the first network call.
 */
class AppServices private constructor(
    val events: EventsRepository,
    val orgs: OrganizationsRepository,
    val profiles: ProfileRepository
) {
    companion object {
        @Volatile private var instance: AppServices? = null

        fun shared(): AppServices = instance ?: synchronized(this) {
            instance ?: build().also { instance = it }
        }

        private fun build(): AppServices {
            val configured = BuildConfig.BUZZ_SUPABASE_URL.isNotBlank() &&
                BuildConfig.BUZZ_SUPABASE_ANON_KEY.isNotBlank()
            return AppServices(
                events = if (configured) SupabaseEventsRepository() else MockEventsRepository(),
                orgs = MockOrganizationsRepository(),
                profiles = MockProfileRepository()
            )
        }

        /** Mirrors iOS `resetForAccountSwitch` — wipes per-account state on sign-out/in. */
        fun resetForAccountSwitch() {
            synchronized(this) { instance = null }
        }
    }
}
