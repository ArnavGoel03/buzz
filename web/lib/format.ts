import { formatDistanceToNow, format, isToday, isTomorrow } from "date-fns";

export function formatRelativeTime(iso: string): string {
  const date = new Date(iso);
  const now = Date.now();
  const diffMs = date.getTime() - now;
  const absMs = Math.abs(diffMs);

  // Under an hour — "in 45m" / "45m ago"
  if (absMs < 3600_000) {
    return formatDistanceToNow(date, { addSuffix: true });
  }
  if (isToday(date)) return `Today · ${format(date, "h:mm a")}`;
  if (isTomorrow(date)) return `Tomorrow · ${format(date, "h:mm a")}`;
  return format(date, "EEE, MMM d · h:mm a");
}

export function formatFullDate(iso: string): string {
  return format(new Date(iso), "EEEE, MMMM d · h:mm a");
}
