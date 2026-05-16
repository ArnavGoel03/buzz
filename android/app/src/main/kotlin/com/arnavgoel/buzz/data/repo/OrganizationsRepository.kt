package com.arnavgoel.buzz.data.repo

import com.arnavgoel.buzz.data.model.Organization
import com.arnavgoel.buzz.data.model.OrganizationCategory

interface OrganizationsRepository {
    suspend fun trending(campus: String): List<Organization>
    suspend fun search(query: String, campus: String): List<Organization>
    suspend fun organization(handle: String): Organization?
}

class MockOrganizationsRepository : OrganizationsRepository {
    private val seed = listOf(
        Organization("aaaa", "ACM at UCSD", "acm-ucsd", "Computer science for everyone.",
            category = OrganizationCategory.ACADEMIC, campus = "ucsd",
            memberCount = 412, accentHex = "#0A85FF", isVerified = true,
            instagramHandle = "acm.ucsd"),
        Organization("bbbb", "Sigma Phi", "sigma-phi", "Brotherhood, philanthropy, and field day.",
            category = OrganizationCategory.GREEK, campus = "ucsd",
            memberCount = 88, accentHex = "#FF2D92", isVerified = true),
        Organization("cccc", "Buzz Official", "buzz-official", "Campus-wide announcements + free food intel.",
            category = OrganizationCategory.GENERAL, campus = "ucsd",
            memberCount = 1_204, accentHex = "#C850FF", isVerified = true),
        Organization("dddd", "Indian Student Association", "isa-ucsd", "Diwali, Holi, and chai.",
            category = OrganizationCategory.CULTURAL, campus = "ucsd",
            memberCount = 234, accentHex = "#FF9F0A", isVerified = true),
        Organization("eeee", "Triton Lacrosse", "lacrosse", "Practice 7am Tue/Thu. New players welcome.",
            category = OrganizationCategory.SPORTS, campus = "ucsd",
            memberCount = 41, accentHex = "#30D158", isVerified = false)
    )

    override suspend fun trending(campus: String) = seed.filter { it.campus == campus }.sortedByDescending { it.memberCount }
    override suspend fun search(query: String, campus: String) = seed.filter {
        it.campus == campus && (it.name.contains(query, ignoreCase = true) || it.handle.contains(query, ignoreCase = true))
    }
    override suspend fun organization(handle: String) = seed.firstOrNull { it.handle == handle }
}
