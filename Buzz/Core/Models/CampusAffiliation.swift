import Foundation

/// One verified relationship between a user and a campus. A user can have many of these
/// — past, present, primary, secondary — to handle transfers (incl. international),
/// dual enrollment, study abroad, joint degrees, alumni status, faculty/staff, and
/// consortium cross-registration.
///
/// Profile creation is intended to be **one time** for the entire college journey.
/// The durable identity is the user's Sign-in-with-Apple ID; verification methods (`.edu`
/// OTP, institutional email, ID card scan, peer attestation) are recorded per affiliation
/// and can vary over time without disrupting the profile.
struct CampusAffiliation: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var campus: String                  // e.g. "ucsd", "iit-bombay"
    var subCampus: String?              // e.g. "warren" (residential college) or "h4" (hostel)
    var role: AffiliationRole
    var program: ProgramKind
    var status: AffiliationStatus
    var year: AcademicYear?             // only meaningful when role == .student
    var major: String?                  // a.k.a. "branch" in Indian colleges
    var minors: [String]
    var verifiedAt: Date?               // when this specific affiliation was verified
    var verificationMethod: VerificationMethod?
    var startDate: Date?
    var endDate: Date?                  // nil while active
}

enum VerificationMethod: String, Codable, CaseIterable, Hashable, Sendable {
    case eduOTP                         // US .edu email OTP
    case institutionalEmailDomain       // e.g. @iitb.ac.in, @bits-pilani.ac.in
    case idCardScan                     // OCR'd student ID with manual fallback
    case peerAttestation                // 3 already-verified students at same campus vouched
    case manualReview                   // admin-verified for edge cases
    case importedFromTransfer           // manually carried over by support during institution change
}

enum AffiliationRole: String, Codable, CaseIterable, Hashable, Sendable {
    case student
    case alumni
    case faculty
    case staff
    case visiting                       // visiting student from another school
    case exchange                       // formal exchange program enrollee
}

enum ProgramKind: String, Codable, CaseIterable, Hashable, Sendable {
    case undergraduate
    case graduate                       // MS, MA
    case professional                   // JD, MD, MBA, etc.
    case doctoral                       // PhD
    case certificate
    case continuingEd
    case dualEnrollment                 // concurrent at multiple institutions
    case studyAbroad
    case exchange                       // marks an affiliation that represents an exchange placement
    case online                         // online-only programs (ASU Online, etc.)
}

enum AffiliationStatus: String, Codable, CaseIterable, Hashable, Sendable {
    case active                         // currently enrolled
    case onLeave                        // approved leave of absence
    case paused                         // stop-out, may return
    case graduated
    case transferred                    // left for another institution
    case withdrawn
}

enum AcademicYear: String, Codable, CaseIterable, Hashable, Sendable {
    case freshman, sophomore, junior, senior, graduate, alumni

    var displayName: String {
        switch self {
        case .freshman: "Freshman"
        case .sophomore: "Sophomore"
        case .junior: "Junior"
        case .senior: "Senior"
        case .graduate: "Graduate"
        case .alumni: "Alumni"
        }
    }
}
