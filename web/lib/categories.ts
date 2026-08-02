import { COLOR } from "./tokens";

/**
 * The one place a category is defined. Colour comes from design/tokens.json via
 * lib/tokens.ts, the label lives beside it, and `EventCategory` is derived from the
 * keys, so adding a category is a single edit here plus a hue in tokens.json.
 *
 * Nothing in the app should ever write a category hex or a category label again.
 */
export const CATEGORIES = {
  party: { color: COLOR.categoryParty, label: "Party", plural: "Parties" },
  free_food: { color: COLOR.categoryFood, label: "Free food", plural: "Free food" },
  club: { color: COLOR.categoryClub, label: "Club", plural: "Clubs" },
  sports: { color: COLOR.categorySports, label: "Sports", plural: "Sports" },
  academic: { color: COLOR.categoryAcademic, label: "Academic", plural: "Academic" },
  greek: { color: COLOR.categoryClub, label: "Greek", plural: "Greek" },
  career: { color: COLOR.categoryAcademic, label: "Career", plural: "Career" },
  other: { color: COLOR.textTertiary, label: "Other", plural: "Other" },
} as const;

export type EventCategory = keyof typeof CATEGORIES;

export const CATEGORY_KEYS = Object.keys(CATEGORIES) as EventCategory[];

/** Tint strength for category-coloured backgrounds. One number, one meaning. */
const SOFT_ALPHA = 0.14;

function withAlpha(hex: string, alpha: number): string {
  const h = hex.replace("#", "");
  const n = parseInt(h.length === 3 ? h.split("").map((c) => c + c).join("") : h.slice(0, 6), 16);
  return `rgba(${(n >> 16) & 255}, ${(n >> 8) & 255}, ${n & 255}, ${alpha})`;
}

/** Falls back to `other` so an unknown category from the database still renders. */
function entry(cat: EventCategory) {
  return CATEGORIES[cat] ?? CATEGORIES.other;
}

export function categoryColor(cat: EventCategory): { color: string; soft: string } {
  const { color } = entry(cat);
  return { color, soft: withAlpha(color, SOFT_ALPHA) };
}

export function categoryLabel(cat: EventCategory): string {
  return entry(cat).label;
}

/** Filter chips and section headings read the plural form. */
export function categoryPlural(cat: EventCategory): string {
  return entry(cat).plural;
}
