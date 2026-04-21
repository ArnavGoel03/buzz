// Email-domain → campus map. Keeps sign-in honest: someone typing alex@ucsd.edu
// gets auto-verified as a UCSD student. Domains not in this list get funneled to
// the waitlist ("we don't support your campus yet").
//
// Extend this list every time a new campus launches. Lowercase keys, required.

export type CampusDomainEntry = {
  campusId: string;
  campusName: string;
  country: string;
};

export const CAMPUS_DOMAINS: Record<string, CampusDomainEntry> = {
  "ucsd.edu":         { campusId: "ucsd",     campusName: "UC San Diego", country: "USA" },
  "ucla.edu":         { campusId: "ucla",     campusName: "UCLA",          country: "USA" },
  "berkeley.edu":     { campusId: "ucb",      campusName: "UC Berkeley",   country: "USA" },
  "stanford.edu":     { campusId: "stanford", campusName: "Stanford",      country: "USA" },
  "mit.edu":          { campusId: "mit",      campusName: "MIT",           country: "USA" },
  "harvard.edu":      { campusId: "harvard",  campusName: "Harvard",       country: "USA" },
  "college.harvard.edu": { campusId: "harvard", campusName: "Harvard",     country: "USA" },
  "g.harvard.edu":    { campusId: "harvard",  campusName: "Harvard",       country: "USA" },
  "caltech.edu":      { campusId: "caltech",  campusName: "Caltech",       country: "USA" },
  "princeton.edu":    { campusId: "princeton",campusName: "Princeton",     country: "USA" },
  "yale.edu":         { campusId: "yale",     campusName: "Yale",          country: "USA" },
  "columbia.edu":     { campusId: "columbia", campusName: "Columbia",      country: "USA" },
  "nyu.edu":          { campusId: "nyu",      campusName: "NYU",           country: "USA" },
  "cmu.edu":          { campusId: "cmu",      campusName: "Carnegie Mellon", country: "USA" },
  "cornell.edu":      { campusId: "cornell",  campusName: "Cornell",       country: "USA" },

  // International — same gate, different suffixes
  "iitb.ac.in":       { campusId: "iitb",     campusName: "IIT Bombay",    country: "India" },
  "iitd.ac.in":       { campusId: "iitd",     campusName: "IIT Delhi",     country: "India" },
  "ox.ac.uk":         { campusId: "oxford",   campusName: "Oxford",        country: "UK" },
  "cam.ac.uk":        { campusId: "cambridge",campusName: "Cambridge",     country: "UK" },
  "utoronto.ca":      { campusId: "utoronto", campusName: "U of Toronto",  country: "Canada" },
};

// Accept any `.edu`, `.ac.uk`, `.edu.in`, `.ac.in`, `.ac.nz`, `.edu.au`, `.ac.ca`
// so students at schools we haven't hard-coded still get gated correctly and land
// on the waitlist instead of bouncing off the form.
const ACADEMIC_SUFFIXES = [
  ".edu", ".ac.uk", ".ac.in", ".edu.in", ".edu.au", ".ac.nz", ".ac.ca", ".ac.il",
];

export function isAcademicEmail(email: string): boolean {
  const lower = email.trim().toLowerCase();
  if (!lower.includes("@")) return false;
  const domain = lower.split("@")[1];
  if (!domain) return false;
  return ACADEMIC_SUFFIXES.some((suf) => domain.endsWith(suf));
}

export function resolveCampus(email: string): CampusDomainEntry | null {
  const domain = email.trim().toLowerCase().split("@")[1];
  if (!domain) return null;
  return CAMPUS_DOMAINS[domain] ?? null;
}

/** Error message for rejected emails — short and actionable. */
export function rejectReason(email: string): string | null {
  const trimmed = email.trim();
  if (!trimmed) return "Enter your school email.";
  if (!trimmed.includes("@")) return "That's not an email address.";
  if (!isAcademicEmail(trimmed)) {
    return "Buzz only accepts school emails (.edu, .ac.uk, .ac.in, .edu.au, etc.).";
  }
  return null;
}
