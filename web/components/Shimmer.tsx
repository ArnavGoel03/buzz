// Shimmer-animated skeleton. Two bands of light pass across the placeholder while
// async data is fetched. Used by route-level loading.tsx files.
export function SkeletonBlock({
  className,
  rounded = "rounded-xl",
}: {
  className?: string;
  rounded?: string;
}) {
  return (
    <div
      className={`relative overflow-hidden bg-[var(--color-surface)] ${rounded} ${className ?? ""}`}
    >
      <div
        className="absolute inset-0"
        style={{
          background:
            "linear-gradient(110deg, transparent 35%, rgba(255,255,255,0.06) 50%, transparent 65%)",
          animation: "shimmer 1.8s linear infinite",
          backgroundSize: "200% 100%",
        }}
      />
      <style>{`@keyframes shimmer { 0% { background-position: -200% 0; } 100% { background-position: 200% 0; } }`}</style>
    </div>
  );
}

export function SkeletonText({ width = "100%", height = 12 }: { width?: string; height?: number }) {
  return (
    <div
      className="relative overflow-hidden bg-[var(--color-surface)] rounded-md"
      style={{ width, height }}
    >
      <div
        className="absolute inset-0"
        style={{
          background:
            "linear-gradient(110deg, transparent 35%, rgba(255,255,255,0.06) 50%, transparent 65%)",
          animation: "shimmer 1.8s linear infinite",
          backgroundSize: "200% 100%",
        }}
      />
    </div>
  );
}

export function EventCardSkeleton() {
  return (
    <div className="rim rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] p-5 h-44">
      <div className="flex items-center justify-between">
        <SkeletonBlock className="h-5 w-20" rounded="rounded-full" />
        <SkeletonBlock className="h-3 w-12" rounded="rounded" />
      </div>
      <SkeletonBlock className="h-6 w-3/4 mt-4" />
      <SkeletonBlock className="h-3 w-full mt-2" />
      <SkeletonBlock className="h-3 w-5/6 mt-1.5" />
      <div className="flex items-center gap-2 mt-5">
        <SkeletonBlock className="h-3 w-24" />
        <SkeletonBlock className="h-3 w-12" />
      </div>
    </div>
  );
}

export function BentoSkeleton() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-6 gap-3 md:gap-4">
      <div className="md:col-span-4 md:row-span-2">
        <SkeletonBlock className="h-72 md:h-full" rounded="rounded-2xl" />
      </div>
      {Array.from({ length: 6 }).map((_, i) => (
        <div key={i} className="md:col-span-2">
          <EventCardSkeleton />
        </div>
      ))}
    </div>
  );
}
