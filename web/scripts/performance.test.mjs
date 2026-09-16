import test from "node:test";
import assert from "node:assert/strict";
import { eventPage, mockOrgEventPage, parseEventCursor, queryOrgEventPage, ORG_EVENT_PAGE_SIZE } from "../lib/org-events.ts";
import { whenNearViewport } from "../lib/near-viewport.ts";

const rows = Array.from({ length: 1051 }, (_, i) => ({ id: `00000000-0000-4000-8000-${String(i).padStart(12, "0")}`, starts_at: "2026-09-17T10:00:00.000Z", host_handle: "club", title: String(i) }));
test("all 1051 organization events remain reachable across duplicate-date pages", () => {
  const seen = []; let cursor;
  do {
    const page = mockOrgEventPage([...rows, { ...rows[0], id: "other", host_handle: "other" }], "club", cursor);
    assert.ok(page.events.length <= ORG_EVENT_PAGE_SIZE);
    seen.push(...page.events.map(row => row.id)); cursor = page.next;
  } while (cursor);
  assert.deepEqual(seen, rows.map(row => row.id));
  assert.equal(new Set(seen).size, rows.length);
});
test("cursor preserves database microseconds and rejects filter injection", () => {
  const precise = rows.slice(0, 26).map(row => ({ ...row, starts_at: "2026-09-17T10:00:00.123456+00:00" }));
  assert.equal(parseEventCursor(eventPage(precise).next).date, precise[0].starts_at);
  for (const value of ["!", "x".repeat(513), Buffer.from(JSON.stringify({ date: rows[0].starts_at, id: "id),host_handle.eq.other" })).toString("base64url"), Buffer.from(JSON.stringify({ date: "not a date", id: "id" })).toString("base64url")]) assert.equal(parseEventCursor(value), null);
});
test("real query adapter scopes organization, orders ties and limits before transport", async () => {
  const calls = []; const query = {};
  for (const method of ["select", "eq", "order", "limit", "or"]) query[method] = (...args) => { calls.push([method, ...args]); return query; };
  query.then = resolve => Promise.resolve(resolve({ data: rows.slice(25, 51), error: null }));
  const client = { from: table => { assert.equal(table, "events"); return query; } };
  const cursor = eventPage(rows).next;
  const page = await queryOrgEventPage(client, "club", cursor);
  assert.deepEqual(calls, [["select", "*"], ["eq", "host_handle", "club"], ["order", "starts_at", { ascending: true }], ["order", "id", { ascending: true }], ["limit", 26], ["or", `starts_at.gt.${rows[24].starts_at},and(starts_at.eq.${rows[24].starts_at},id.gt.${rows[24].id})`]]);
  assert.equal(page.events.length, 25); assert.ok(page.next);
});
test("database errors propagate rather than masquerading as an empty archive", async () => {
  const query = { then: resolve => Promise.resolve(resolve({ data: null, error: new Error("unavailable") })) };
  for (const method of ["select", "eq", "order", "limit"]) query[method] = () => query;
  await assert.rejects(queryOrgEventPage({ from: () => query }, "club"), /unavailable/);
});
test("map activation waits for intersection, runs once and disconnects", () => {
  let callback; let activated = 0; let disconnected = 0;
  class Observer {
    constructor(cb, options) { callback = cb; assert.equal(options.rootMargin, "200px"); }
    observe() {} disconnect() { disconnected++; }
  }
  const stop = whenNearViewport({}, () => activated++, Observer);
  callback([{ isIntersecting: false }]); assert.equal(activated, 0);
  callback([{ isIntersecting: true }]); callback([{ isIntersecting: true }]); assert.equal(activated, 1);
  stop(); assert.ok(disconnected >= 1);
});
test("unmounted map never activates; older browsers use the immediate fallback", () => {
  let callback; let activated = 0;
  class Observer { constructor(cb) { callback = cb; } observe() {} disconnect() {} }
  whenNearViewport({}, () => activated++, Observer)(); callback([{ isIntersecting: true }]); assert.equal(activated, 0);
  whenNearViewport({}, () => activated++, null); assert.equal(activated, 1);
});

test("malformed database IDs and calendar rollover dates cannot reach cursor filters", async () => {
  for (const cursor of [{ date: rows[0].starts_at, id: "slug" }, { date: "2026-02-31T10:00:00Z", id: rows[0].id }]) {
    const encoded = Buffer.from(JSON.stringify(cursor)).toString("base64url");
    assert.equal(parseEventCursor(encoded), null);
    let filtered = false;
    const query = { then: resolve => Promise.resolve(resolve({ data: [], error: null })), or: () => { filtered = true; return query; } };
    for (const method of ["select", "eq", "order", "limit"]) query[method] = () => query;
    await queryOrgEventPage({ from: () => query }, "club", encoded);
    assert.equal(filtered, false);
  }
});
