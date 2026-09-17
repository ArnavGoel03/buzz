import { test, expect } from "@playwright/test";
import { PAGE_LOAD_ERROR, TRY_AGAIN } from "../lib/error-copy";

for (const [name, viewport] of [["desktop", { width: 1440, height: 700 }], ["phone", { width: 390, height: 844 }]] as const) {
  test(`${name}: unavailable events preserve the organization and offer a fresh retry`, async ({ page }, testInfo) => {
    await page.setViewportSize(viewport);
    const response = await page.goto("http://127.0.0.1:3108/o/acm-ucsd");
    expect(response?.status()).toBe(200);
    await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
    await expect(page.getByRole("alert").filter({ hasText: PAGE_LOAD_ERROR })).toHaveText(PAGE_LOAD_ERROR);
    await expect(page.getByText("No events scheduled yet.", { exact: true })).toHaveCount(0);
    await expect(page.getByRole("navigation", { name: "Events", exact: true })).toHaveCount(0);
    const retry = page.getByRole("link", { name: TRY_AGAIN, exact: true });
    await expect(retry).toHaveAttribute("href", "/o/acm-ucsd");
    await retry.focus();
    await expect(retry).toBeFocused();
    await Promise.all([page.waitForEvent("domcontentloaded"), retry.press("Enter")]);
    await expect(page.getByRole("alert").filter({ hasText: PAGE_LOAD_ERROR })).toHaveText(PAGE_LOAD_ERROR);
    await page.screenshot({ path: testInfo.outputPath(`${name}-organization-unavailable.png`), fullPage: true });
  });
}
