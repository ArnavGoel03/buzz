package com.arnavgoel.buzz

import android.app.Application

class BuzzApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialise lightweight singletons here. The Supabase client is lazy
        // (see data/SupabaseClient.kt) so it doesn't need explicit init.
    }
}
