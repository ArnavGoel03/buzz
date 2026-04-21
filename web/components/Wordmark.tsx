// Kerned wordmark — distinctive without leaning on a generic "star" icon.
// The italic Z with Fraunces WONK axis is the whole personality.
export default function Wordmark() {
  return (
    <span
      className="font-display text-xl leading-none tracking-[-0.04em] font-medium select-none"
      style={{ fontFamily: "var(--font-display)", fontVariationSettings: "'opsz' 24" }}
    >
      bu<em className="italic text-[var(--color-accent)]" style={{ fontVariationSettings: "'WONK' 1" }}>zz</em>
      <span className="ml-1 text-[var(--color-text-tertiary)]">·</span>
    </span>
  );
}
