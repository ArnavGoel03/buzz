import { SkeletonBlock } from "@/components/Shimmer";

export default function Loading() {
  return (
    <article>
      <SkeletonBlock className="h-48 md:h-64 w-full" rounded="rounded-none" />
      <div className="max-w-3xl mx-auto px-4 md:px-8 -mt-16">
        <SkeletonBlock className="h-24 w-24" rounded="rounded-2xl" />
        <SkeletonBlock className="h-9 w-3/5 mt-5" />
        <SkeletonBlock className="h-4 w-1/2 mt-3" />
        <SkeletonBlock className="h-11 w-28 mt-5" rounded="rounded-xl" />
        <SkeletonBlock className="h-4 w-full mt-10" />
        <SkeletonBlock className="h-4 w-11/12 mt-2" />
        <div className="grid gap-3 mt-10 md:grid-cols-2">
          {Array.from({ length: 4 }).map((_, i) => (
            <SkeletonBlock key={i} className="h-32 w-full" rounded="rounded-2xl" />
          ))}
        </div>
      </div>
    </article>
  );
}
