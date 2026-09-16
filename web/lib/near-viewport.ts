/** Activate once near the viewport; never activate after unmount. */
export function whenNearViewport(element: Element, activate: () => void, Observer = globalThis.IntersectionObserver) {
  let stopped = false;
  if (!Observer) { activate(); return () => { stopped = true; }; }
  const observer = new Observer(entries => {
    if (stopped || !entries.some(entry => entry.isIntersecting)) return;
    stopped = true;
    observer.disconnect();
    activate();
  }, { rootMargin: "200px" });
  observer.observe(element);
  return () => { stopped = true; observer.disconnect(); };
}
