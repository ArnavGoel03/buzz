/**
 * The academic-suffix rules, split out from lib/campus-domains.ts so client
 * components can validate an address without pulling the 200KB university dataset
 * into the browser bundle. campus-domains.ts imports from here, so the suffix list
 * still exists in exactly one place.
 */

export const ACADEMIC_SUFFIXES = [
  ".edu", ".ac.uk", ".ac.in", ".edu.in", ".edu.au", ".ac.nz", ".ac.ca",
  ".ac.il", ".ac.jp", ".ac.kr", ".edu.sg", ".edu.hk", ".ac.za",
];

export const COUNTRY_BY_SUFFIX: Record<string, string> = {
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

/** Null when the address is usable. Otherwise the sentence to show the student. */
export function rejectReason(email: string): string | null {
  const t = email.trim();
  if (!t) return "Enter your school email.";
  if (!t.includes("@")) return "That is not an email address.";
  if (!isAcademicEmail(t)) {
    return "Buzz uses your school email to check you are a real student (.edu, .ac.uk, .ac.in, .edu.au, and the rest).";
  }
  return null;
}
