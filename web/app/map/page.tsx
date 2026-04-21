import EventMap from "@/components/EventMap";
import MapOverlayCTA from "@/components/MapOverlayCTA";
import { getFeedEvents, getActiveCampus } from "@/lib/data";

export const revalidate = 60;
export const metadata = { title: "Live map" };

export default async function MapPage() {
  const [events, campus] = await Promise.all([getFeedEvents(), getActiveCampus()]);
  return (
    <div className="relative h-[calc(100vh-3.5rem-4rem)] md:h-[calc(100vh-3.5rem)]">
      <EventMap
        events={events}
        center={{ lat: campus.center_lat, lng: campus.center_lng }}
        zoom={14.5}
      />
      <MapOverlayCTA />
    </div>
  );
}
