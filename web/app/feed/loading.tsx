import { BentoSkeleton, SkeletonBlock } from "@/components/Shimmer";

export default function Loading() {
  return (
    <div>
      <section className="px-4 md:px-8 pt-8 md:pt-14 pb-10">
        <SkeletonBlock className="h-4 w-60 mb-5" rounded="rounded-md" />
        <SkeletonBlock className="h-16 md:h-24 w-3/4 max-w-3xl" />
        <div className="mt-6 flex gap-10">
          <SkeletonBlock className="h-12 w-16" />
          <SkeletonBlock className="h-4 w-80 max-w-full mt-3" />
        </div>
        <div className="mt-8 flex gap-3">
          <SkeletonBlock className="h-11 w-36 rounded-xl" />
          <SkeletonBlock className="h-11 w-32 rounded-xl" />
        </div>
      </section>
      <div className="border-y border-[var(--color-border)] py-4 px-4 md:px-8">
        <SkeletonBlock className="h-5 w-full max-w-5xl mx-auto" />
      </div>
      <section className="px-4 md:px-8 py-10">
        <SkeletonBlock className="h-7 w-48 mb-5" />
        <BentoSkeleton />
      </section>
    </div>
  );
}
