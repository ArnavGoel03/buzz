import { defineConfig } from "@playwright/test";
export default defineConfig({
  testDir: "./browser-tests",
  workers: 1,
  retries: 0,
  use: { baseURL: "http://127.0.0.1:3107", trace: "retain-on-failure", screenshot: "only-on-failure" },
  webServer: [
    { command: "pnpm start --hostname 127.0.0.1 --port 3107", url: "http://127.0.0.1:3107", reuseExistingServer: false, timeout: 30_000 },
    {
      command: "pnpm start --hostname 127.0.0.1 --port 3108",
      url: "http://127.0.0.1:3108",
      reuseExistingServer: false,
      timeout: 30_000,
      // A closed local endpoint exercises real server fetch failure without credentials.
      env: { NEXT_PUBLIC_SUPABASE_URL: "https://127.0.0.1:1", NEXT_PUBLIC_SUPABASE_ANON_KEY: "test-fixture-only" },
    },
  ],
});
