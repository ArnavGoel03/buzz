"use client";

import { useMemo } from "react";
import Map, { Marker, Popup, NavigationControl } from "react-map-gl/maplibre";
import { useRouter } from "next/navigation";
import type { Event } from "@/lib/types";
import { categoryColor } from "@/lib/categories";
import { useState } from "react";

// Free dark basemap via Carto (no API key required). Good contrast with yellow pins.
const BASEMAP = "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json";

type Props = {
  events: Event[];
  center: { lat: number; lng: number };
  zoom?: number;
  className?: string;
};

export default function EventMap({ events, center, zoom = 14, className }: Props) {
  const router = useRouter();
  const [selected, setSelected] = useState<Event | null>(null);

  const pins = useMemo(
    () => events.filter((e) => e.latitude != null && e.longitude != null),
    [events]
  );

  return (
    <div className={className ?? "w-full h-full"}>
      <Map
        initialViewState={{ latitude: center.lat, longitude: center.lng, zoom }}
        mapStyle={BASEMAP}
        attributionControl={{ compact: true }}
      >
        <NavigationControl position="top-right" showCompass={false} />
        {pins.map((event) => {
          const { color } = categoryColor(event.category);
          return (
            <Marker
              key={event.id}
              latitude={event.latitude!}
              longitude={event.longitude!}
              anchor="center"
              onClick={(e) => {
                e.originalEvent.stopPropagation();
                setSelected(event);
              }}
            >
              <button
                aria-label={event.title}
                className="w-6 h-6 rounded-full border-2 border-white/90 shadow-lg cursor-pointer"
                style={{ background: color }}
              />
            </Marker>
          );
        })}
        {selected && selected.latitude != null && selected.longitude != null && (
          <Popup
            latitude={selected.latitude}
            longitude={selected.longitude}
            anchor="bottom"
            onClose={() => setSelected(null)}
            closeButton={false}
            offset={14}
            className="[&_.maplibregl-popup-content]:bg-[var(--color-surface)] [&_.maplibregl-popup-content]:text-white [&_.maplibregl-popup-content]:rounded-xl [&_.maplibregl-popup-content]:border [&_.maplibregl-popup-content]:border-[var(--color-border)] [&_.maplibregl-popup-tip]:!border-t-[var(--color-surface)]"
          >
            <button
              onClick={() => router.push(`/e/${selected.id}`)}
              className="text-left w-48 p-1"
            >
              <p className="font-bold text-sm leading-snug">{selected.title}</p>
              <p className="mt-1 text-xs text-[var(--color-text-secondary)]">
                {selected.location_name}
              </p>
              <p className="mt-2 text-[11px] text-[var(--color-accent)] font-semibold">
                Tap to view →
              </p>
            </button>
          </Popup>
        )}
      </Map>
    </div>
  );
}
