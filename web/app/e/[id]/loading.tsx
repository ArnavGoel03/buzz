import { SkeletonBlock } from "@/components/Shimmer";

export default function Loading() {
  return (
    <article className="max-w-3xl mx-auto px-4 md:px-8 py-6">
      <SkeletonBlock className="h-44 md:h-56 w-full" rounded="rounded-2xl" />
      <SkeletonBlock className="h-6 w-20 mt-5" rounded="rounded-full" />
      <SkeletonBlock className="h-10 md:h-12 w-4/5 mt-3" />
      <SkeletonBlock className="h-4 w-full mt-4" />
      <SkeletonBlock className="h-4 w-3/4 mt-2" />
      <div className="mt-8 grid gap-2">
        {Array.from({ length: 4 }).map((_, i) => (
          <SkeletonBlock key={i} className="h-14 w-full" rounded="rounded-xl" />
        ))}
      </div>
      <div className="mt-6 grid grid-cols-[1fr_auto] gap-2">
        <SkeletonBlock className="h-12 w-full" rounded="rounded-xl" />
        <SkeletonBlock className="h-12 w-12" rounded="rounded-xl" />
      </div>
    </article>
  );
}
