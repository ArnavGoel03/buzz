import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { createRequire } from "node:module";
import ts from "typescript";
import { createElement } from "react";
import { renderToStaticMarkup } from "react-dom/server";
import * as errorCopy from "../lib/error-copy.ts";
import { queryOrgEventPage, parseEventCursor, eventPage } from "../lib/org-events.ts";

const require = createRequire(import.meta.url);
const source = readFileSync(new URL("../app/o/[handle]/page.tsx", import.meta.url), "utf8");
const compiled = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.CommonJS, jsx: ts.JsxEmit.ReactJSX, target: ts.ScriptTarget.ES2022 } }).outputText;
const org = { handle: "club", name: "Fixture Club", tagline: "Fixture tagline", accent_hex: "#ffffff", member_count: 10 };
const rows = Array.from({ length: 26 }, (_, index) => ({ id: `00000000-0000-4000-8000-${String(index).padStart(12, "0")}`, starts_at: "2026-09-17T10:00:00.123456Z", host_handle: "club", title: `Event ${index}` }));
function queryResult(result) {
  const query = { then: (resolve, reject) => Promise.resolve(result()).then(resolve, reject) };
  for (const method of ["select", "eq", "order", "limit", "or"]) query[method] = () => query;
  return { from: () => query };
}
function loadPage(getEventsByOrg, getOrg = async () => org) {
  const exports = {};
  const dependencies = {
    "@/lib/error-copy": errorCopy,
    "@/lib/data": { getOrg, getEventsByOrg },
    "@/lib/org-events": { parseEventCursor },
    "@/lib/security": { safeJsonLd: JSON.stringify },
    "@/lib/site": { absoluteUrl: path => `https://example.test${path}` },
    "next/navigation": { notFound: () => { throw new Error("NOT_FOUND"); } },
    "next/link": { default: ({ href, children }) => createElement("a", { href: typeof href === "string" ? href : `${href.pathname}?${new URLSearchParams(href.query)}` }, children) },
    "@/components/OrgHero": { default: ({ org }) => createElement("h1", null, org.name) },
    "@/components/EventCard": { default: ({ event }) => createElement("p", { "data-event": event.id }, event.title) },
  };
  const mockedRequire = name => dependencies[name] ?? (name.startsWith("@/components/") ? { default: () => null } : require(name));
  new Function("require", "exports", "console", compiled)(mockedRequire, exports, { error() {} });
  return exports.default;
}
const props = (search = {}) => ({ params: Promise.resolve({ handle: "club" }), searchParams: Promise.resolve(search) });

test("actual organization page preserves its profile when the paginated query fails", async () => {
  const client = queryResult(() => ({ data: rows, error: new Error("Unavailable") }));
  const page = loadPage((handle, cursor) => queryOrgEventPage(client, handle, cursor));
  const after = eventPage(rows).next;
  const html = renderToStaticMarkup(await page(props({ after, page: "2" })));
  assert.match(html, /Fixture Club/);
  assert.match(html, /We hit an error loading this page\./);
  assert.match(html, /Try again/);
  assert.match(html, /role="alert"/);
  assert.ok(html.includes(`after=${encodeURIComponent(after)}`));
  assert.doesNotMatch(html, /No events scheduled yet\.|data-event=|aria-current="page"/);
});

test("empty results are distinct from failure and a fresh request retries the query", async () => {
  let failed = true;
  let calls = 0;
  const client = queryResult(() => { calls++; if (failed) throw new Error("Transport failed"); return { data: [], error: null }; });
  const page = loadPage((handle, cursor) => queryOrgEventPage(client, handle, cursor));
  assert.match(renderToStaticMarkup(await page(props())), /Try again/);
  failed = false;
  const recovered = renderToStaticMarkup(await page(props()));
  assert.match(recovered, /No events scheduled yet\./);
  assert.doesNotMatch(recovered, /role="alert"|Try again/);
  assert.equal(calls, 2);
});

test("successful pagination still renders one complete page and a next link", async () => {
  const page = loadPage((handle, cursor) => queryOrgEventPage(queryResult(() => ({ data: rows, error: null })), handle, cursor));
  const html = renderToStaticMarkup(await page(props()));
  assert.equal((html.match(/data-event=/g) ?? []).length, 25);
  assert.match(html, /aria-current="page"/);
  assert.match(html, /after=/);
  assert.doesNotMatch(html, /Try again/);
});


test("an unknown organization remains not found when event loading also fails", async () => {
  const page = loadPage(async () => { throw new Error("Unavailable"); }, async () => null);
  await assert.rejects(page(props()), /NOT_FOUND/);
});
