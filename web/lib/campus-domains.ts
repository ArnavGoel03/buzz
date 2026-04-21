import usUniversitiesRaw from "@/data/us-universities.json";

// Any academic TLD works as a sign-in gate — the inbox is the verification. New
// school accredited tomorrow? Their student signs in with @newschool.edu and they're
// in, no deploy needed.
//
// On top of that we ship two lookup layers for nice branding:
//   1. FEATURED_DOMAINS  — hand-curated priority schools (nicer names/copy)
//   2. us-universities.json — 2,300+ accredited US schools (refreshable via script)
//
// Cascade: featured → US bundle → derive from domain.

export type CampusResolution = {
  campusId: string;
  campusName: string;
  country: string;
  state?: string | null;
  source: "featured" | "bundled" | "derived";
};

type USEntry = { d: string; n: string; s: string | null };
const US_INDEX: Map<string, USEntry> = new Map(
  (usUniversitiesRaw as USEntry[]).filter((r) => r.d).map((r) => [r.d.toLowerCase(), r])
);

const FEATURED_DOMAINS: Record<string, { campusId: string; campusName: string; country: string }> = {
  "ucsd.edu":         { campusId: "ucsd",     campusName: "UC San Diego", country: "USA" },
  "ucla.edu":         { campusId: "ucla",     campusName: "UCLA",          country: "USA" },
  "berkeley.edu":     { campusId: "ucb",      campusName: "UC Berkeley",   country: "USA" },
  "stanford.edu":     { campusId: "stanford", campusName: "Stanford",      country: "USA" },
  "mit.edu":          { campusId: "mit",      campusName: "MIT",           country: "USA" },
  "harvard.edu":      { campusId: "harvard",  campusName: "Harvard",       country: "USA" },
  "college.harvard.edu": { campusId: "harvard", campusName: "Harvard",     country: "USA" },
  "caltech.edu":      { campusId: "caltech",  campusName: "Caltech",       country: "USA" },
  "princeton.edu":    { campusId: "princeton",campusName: "Princeton",     country: "USA" },
  "yale.edu":         { campusId: "yale",     campusName: "Yale",          country: "USA" },
  "columbia.edu":     { campusId: "columbia", campusName: "Columbia",      country: "USA" },
  "nyu.edu":          { campusId: "nyu",      campusName: "NYU",           country: "USA" },
  "cmu.edu":          { campusId: "cmu",      campusName: "Carnegie Mellon", country: "USA" },
  "cornell.edu":      { campusId: "cornell",  campusName: "Cornell",       country: "USA" },
  "iitb.ac.in":       { campusId: "iitb",     campusName: "IIT Bombay",    country: "India" },
  "iitd.ac.in":       { campusId: "iitd",     campusName: "IIT Delhi",     country: "India" },
  "ox.ac.uk":         { campusId: "oxford",   campusName: "Oxford",        country: "UK" },
  "cam.ac.uk":        { campusId: "cambridge",campusName: "Cambridge",     country: "UK" },
  "utoronto.ca":      { campusId: "utoronto", campusName: "U of Toronto",  country: "Canada" },
};

const ACADEMIC_SUFFIXES = [
  ".edu", ".ac.uk", ".ac.in", ".edu.in", ".edu.au", ".ac.nz", ".ac.ca",
  ".ac.il", ".ac.jp", ".ac.kr", ".edu.sg", ".edu.hk", ".ac.za",
];

const COUNTRY_BY_SUFFIX: Record<string, string> = {
  ".edu": "USA", ".ac.uk": "UK", ".ac.in": "India", ".edu.in": "India",
  ".edu.au": "Australia", ".ac.nz": "New Zealand", ".ac.ca": "Canada",
  ".ac.il": "Israel", ".ac.jp": "Japan", ".ac.kr": "South Korea",
  ".edu.sg": "Singapore", ".edu.hk": "Hong Kong", ".ac.za": "South Africa",
};

export function isAcademicEmail(email: string): boolean {
  const lower = email.trim().toLowerCase();
  if (!lower.includes("@")) return false;
  const domain = lower.split("@")[1];
  if (!domain) return false;
  return ACADEMIC_SUFFIXES.some((suf) => domain.endsWith(suf));
}

export function resolveCampus(email: string): CampusResolution | null {
  const lower = email.trim().toLowerCase();
  if (!lower.includes("@")) return null;
  const domain = lower.split("@")[1];
  if (!domain) return null;

  // 1. Featured: hand-picked schools with nice display names
  const featured = FEATURED_DOMAINS[domain];
  if (featured) return { ...featured, source: "featured" };

  // 2. Bundled: 2,300+ US schools from the Hipo dataset (+ root-domain fallback for
  //    subdomains like alumni.xyz.edu → xyz.edu)
  const bundled =
    US_INDEX.get(domain) ??
    US_INDEX.get(domain.split(".").slice(-2).join(".")) ??
    null;
  if (bundled) {
    return {
      campusId: bundled.d.replace(/\./g, "-"),
      campusName: bundled.n,
      country: "USA",
      state: bundled.s,
      source: "bundled",
    };
  }

  // 3. Derived: any academic TLD that we haven't cataloged still lets the user in.
  //    Campus auto-provisioned server-side on first sign-in. Display name = title-
  //    cased first label of the domain ("newcollege" → "Newcollege").
  if (!isAcademicEmail(lower)) return null;
  const suffix = ACADEMIC_SUFFIXES.find((s) => domain.endsWith(s)) ?? ".edu";
  const country = COUNTRY_BY_SUFFIX[suffix] ?? "Other";
  const firstLabel = domain.replace(suffix, "").split(".").at(-1) ?? domain;
  const display = firstLabel.charAt(0).toUpperCase() + firstLabel.slice(1);
  return {
    campusId: domain.replace(/\./g, "-"),
    campusName: display,
    country,
    source: "derived",
  };
}

export function rejectReason(email: string): string | null {
  const t = email.trim();
  if (!t) return "Enter your school email.";
  if (!t.includes("@")) return "That's not an email address.";
  if (!isAcademicEmail(t)) {
    return "Buzz uses your school email to verify you're a real student (.edu, .ac.uk, .ac.in, .edu.au, etc.).";
  }
  return null;
}
