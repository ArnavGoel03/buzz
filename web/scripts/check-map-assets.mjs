import assert from "node:assert/strict";
import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
const root = ".next";
const markers = ["basemaps.cartocdn.com/gl/dark-matter", "MapLibre GL JS", "maplibregl-map{"];
export const mapAssets = new Set(readdirSync(join(root, "static/chunks")).filter(name => markers.some(marker => readFileSync(join(root, "static/chunks", name), "utf8").includes(marker))).map(name => `${root}/static/chunks/${name}`));
assert.ok(mapAssets.size, "Map detector positive control missing");
for (const page of ["index", "feed"]) {
  const html = readFileSync(join(root, `server/app/${page}.html`), "utf8");
  const resources = [...html.matchAll(/(?:src|href)="(\/_next\/[^\"]+)"/g)].map(match => `${root}/${match[1].split("?")[0].slice(7)}`);
  assert.ok(resources.every(resource => !mapAssets.has(resource)), `${page} eagerly references map assets`);
  assert.ok(html.includes("h-[360px]"), `${page} lost reserved map height`);
  console.log(`${page}: map assets absent from initial resources; reserved height retained`);
}
