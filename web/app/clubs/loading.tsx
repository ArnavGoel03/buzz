import { SkeletonBlock } from "@/components/Shimmer";

export default function Loading() {
  return (
    <div className="max-w-5xl mx-auto px-4 md:px-8 py-6">
      <SkeletonBlock className="h-10 w-40 mb-2" />
      <SkeletonBlock className="h-4 w-32 mb-8" />
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {Array.from({ length: 9 }).map((_, i) => (
          <div key={i} className="rim rounded-2xl bg-[var(--color-surface)] border border-[var(--color-border)] p-5 h-32">
            <div className="flex items-center gap-3">
              <SkeletonBlock className="h-12 w-12" rounded="rounded-xl" />
              <div className="flex-1">
                <SkeletonBlock className="h-4 w-3/5 mb-2" />
                <SkeletonBlock className="h-3 w-4/5" />
              </div>
            </div>
            <div className="flex items-center justify-between mt-5">
              <SkeletonBlock className="h-3 w-16" />
              <SkeletonBlock className="h-3 w-24" />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
