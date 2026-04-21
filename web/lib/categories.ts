import type { EventCategory } from "./types";

export function categoryColor(cat: EventCategory): { color: string; soft: string } {
  switch (cat) {
    case "party":    return { color: "#FF2D92", soft: "rgba(255, 45, 146, 0.14)" };
    case "free_food":return { color: "#34C759", soft: "rgba(52, 199, 89, 0.14)" };
    case "greek":    return { color: "#BF5AF2", soft: "rgba(191, 90, 242, 0.14)" };
    case "sports":   return { color: "#FF9500", soft: "rgba(255, 149, 0, 0.14)" };
    case "academic": return { color: "#5AC8FA", soft: "rgba(90, 200, 250, 0.14)" };
    case "career":   return { color: "#0A84FF", soft: "rgba(10, 132, 255, 0.14)" };
    case "club":     return { color: "#FFD60A", soft: "rgba(255, 214, 10, 0.14)" };
    default:         return { color: "#8E8E93", soft: "rgba(142, 142, 147, 0.14)" };
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
