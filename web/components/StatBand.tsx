// Stats band. Every value passed in has to be a real count from the database, not a
// rounded-up number chosen to look busy.
export default function StatBand({
  items,
}: {
  items: { label: string; value: string | number; accent?: boolean }[];
}) {
  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-px rounded-2xl overflow-hidden border border-[var(--color-border)] bg-[var(--color-border)]">
      {items.map((it) => (
        <div key={it.label} className="bg-[var(--color-surface)] p-5">
          <div
            className={`font-display tabular text-3xl md:text-4xl leading-none ${
              it.accent ? "text-[var(--color-accent)]" : ""
            }`}
            style={{ fontFamily: "var(--font-display)" }}
          >
            {it.value}
          </div>
          <div className="mt-2 font-mono text-[10px] uppercase tracking-[0.18em] text-[var(--color-text-tertiary)]">
            {it.label}
          </div>
        </div>
      ))}
    </div>
  );
}
