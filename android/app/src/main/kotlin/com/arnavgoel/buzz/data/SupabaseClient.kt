package com.arnavgoel.buzz.data

import com.arnavgoel.buzz.BuildConfig
import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.auth.Auth
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.postgrest.Postgrest
import io.github.jan.supabase.realtime.Realtime

/// Singleton Supabase client. URL and anon key come from BuildConfig (declared in
/// `app/build.gradle.kts` `buildConfigField`s, sourced from `local.properties`).
/// If either is empty the client is still constructed — calls will fail at request time
/// rather than silently no-op, which surfaces missing config quickly.
object Buzz {
    val supabase: SupabaseClient by lazy {
        createSupabaseClient(
            supabaseUrl = BuildConfig.BUZZ_SUPABASE_URL,
            supabaseKey = BuildConfig.BUZZ_SUPABASE_ANON_KEY
        ) {
            install(Postgrest)
            install(Auth)
            install(Realtime)
        }
    }
}
