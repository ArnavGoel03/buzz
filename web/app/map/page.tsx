"use client";

import { useState, useMemo, useEffect } from "react";
import EventMap from "@/components/EventMap";
import MapOverlayCTA from "@/components/MapOverlayCTA";
import MapStatsPanel from "@/components/MapStatsPanel";
import MapFilterChips from "@/components/MapFilterChips";
import { mockEvents, mockCampus } from "@/lib/mock-data";
import type { EventCategory } from "@/lib/types";

export default function MapPage() {
  const [filter, setFilter] = useState<EventCategory | "all">("all");
  const events = useMemo(() => {
    if (filter === "all") return mockEvents;
    return mockEvents.filter((e) => e.category === filter);
  }, [filter]);

  useEffect(() => {
    document.title = "Live map · Buzz";
  }, []);

  return (
    <div className="relative h-[calc(100vh-3.5rem-4rem)] md:h-[calc(100vh-3.5rem)]">
      <EventMap
        events={events}
        center={{ lat: mockCampus.center_lat, lng: mockCampus.center_lng }}
        zoom={14.5}
      />
      <MapStatsPanel events={events} campusName={mockCampus.name} />
      <MapFilterChips selected={filter} onSelect={setFilter} />
      <MapOverlayCTA />
    </div>
  );
}
