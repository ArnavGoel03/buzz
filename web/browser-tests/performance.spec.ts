import { test, expect } from "@playwright/test";
import { mapAssets } from "../scripts/check-map-assets.mjs";
const mapPaths = new Set([...mapAssets].map(path => path.replace(".next/", "/_next/")));
for (const [name, viewport] of [["desktop", { width: 1440, height: 700 }], ["phone", { width: 390, height: 844 }]] as const) {
  test(`${name}: maps defer, activate and navigate`, async ({ page }, testInfo) => {
    await page.setViewportSize(viewport);
    const requests: string[] = [];
    let styles = 0;
    page.on("request", request => requests.push(new URL(request.url()).pathname));
    // Exercise the real map engine deterministically without a third-party tile service.
    await page.route("https://basemaps.cartocdn.com/**", async route => {
      styles++;
      await route.fulfill({ json: { version: 8, sources: {}, layers: [{ id: "background", type: "background", paint: { "background-color": "#161616" } }] } });
    });
    for (const path of ["/", "/feed"]) {
      requests.length = 0; styles = 0;
      await page.goto(path);
      const map = page.locator("[data-deferred-map]");
      await expect(map).toBeAttached();
      const box = await map.boundingBox();
      expect.soft(box?.y).toBeGreaterThan(viewport.height + 200);
      await page.waitForTimeout(350);
      expect.soft(styles).toBe(0);
      expect.soft(requests.filter(path => mapPaths.has(path))).toEqual([]);
      await map.scrollIntoViewIfNeeded();
      await expect(map.locator("canvas")).toBeVisible();
      await expect.poll(() => styles).toBeGreaterThan(0);
      await expect.soft(map.locator("..")).toHaveCSS("height", "360px");
      await page.screenshot({ path: testInfo.outputPath(`${name}-${path === "/" ? "home" : "feed"}-map.png`) });
      const marker = map.getByRole("button", { name: "ACM Boba Night", exact: true });
      await marker.click();
      await map.getByText("Tap to view", { exact: false }).click();
      await expect(page).toHaveURL(/\/e\/acm-boba$/);
    }
    await page.goto("/o/acm-ucsd");
    await expect(page.getByRole("heading", { name: "Events", exact: true })).toBeVisible();
    await page.screenshot({ path: testInfo.outputPath(`${name}-organization.png`), fullPage: true });
  });
}
