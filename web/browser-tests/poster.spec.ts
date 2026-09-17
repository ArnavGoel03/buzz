import { test, expect } from "@playwright/test";
import { writeFile } from "node:fs/promises";

test("poster routes return complete PNGs and reject invalid IDs", async ({ request }, info) => {
  for (const [format, width, height] of [["og", 1200, 630], ["story", 1080, 1920]] as const) {
    const response = await request.get(`/api/poster/fixture?format=${format}`);
    expect(response.status()).toBe(200);
    expect(response.headers()["content-type"]).toBe("image/png");
    const bytes = await response.body();
    expect([...bytes.subarray(0, 8)]).toEqual([137, 80, 78, 71, 13, 10, 26, 10]);
    expect([bytes.readUInt32BE(16), bytes.readUInt32BE(20)]).toEqual([width, height]);
    await writeFile(info.outputPath(`poster-${format}.png`), bytes);
  }
  expect((await request.get("/api/poster/%21")).status()).toBe(400);
});
