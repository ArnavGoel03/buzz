import type { EventCategory } from "./types";

/**
 * Category hues — mirror design/tokens.json exactly. Update tokens.json + re-run
 * `node scripts/sync-tokens.mjs` whenever these need to change; do not edit values here.
 */
export function categoryColor(cat: EventCategory): { color: string; soft: string } {
  switch (cat) {
    case "party":     return { color: "#FF2D92", soft: "rgba(255, 45, 146, 0.14)" };
    case "free_food": return { color: "#FF9F0A", soft: "rgba(255, 159, 10, 0.14)" };
    case "greek":     return { color: "#BF59F2", soft: "rgba(191, 89, 242, 0.14)" };
    case "sports":    return { color: "#30D158", soft: "rgba(48, 209, 88, 0.14)" };
    case "academic":  return { color: "#0A85FF", soft: "rgba(10, 133, 255, 0.14)" };
    case "career":    return { color: "#0A85FF", soft: "rgba(10, 133, 255, 0.14)" };
    case "club":      return { color: "#BF59F2", soft: "rgba(191, 89, 242, 0.14)" };
    default:          return { color: "#8E8E93", soft: "rgba(142, 142, 147, 0.14)" };
  }
}

export function categoryLabel(cat: EventCategory): string {
  switch (cat) {
    case "free_food": return "Free food";
    case "greek":     return "Greek";
    case "academic":  return "Academic";
    case "career":    return "Career";
    default:          return cat[0].toUpperCase() + cat.slice(1);
  }
}
