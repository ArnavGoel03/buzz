/**
 * Web Push subscription helper. Called after the user accepts push permission in the
 * browser (typically triggered from an "Enable free-food alerts" CTA).
 *
 * Production setup:
 *   1. Generate a VAPID keypair: `npx web-push generate-vapid-keys`
 *   2. Set NEXT_PUBLIC_VAPID_PUBLIC_KEY + VAPID_PRIVATE_KEY env vars
 *   3. The public key gets baked into the client subscription; private key signs
 *      outbound push requests in /api/push/send
 */

export async function subscribeToPush(profileID: string): Promise<boolean> {
  if (typeof window === "undefined" || !("serviceWorker" in navigator) || !("PushManager" in window)) {
    return false;
  }
  const reg = await navigator.serviceWorker.ready;
  const permission = await Notification.requestPermission();
  if (permission !== "granted") return false;

  const vapidKey = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY;
  if (!vapidKey) return false;

  const subscription = await reg.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: urlBase64ToUint8Array(vapidKey) as BufferSource,
  });

  await fetch("/api/push/token", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      profile_id: profileID,
      platform: "web_push",
      token: JSON.stringify(subscription),
    }),
  });

  return true;
}

function urlBase64ToUint8Array(b64: string): Uint8Array {
  const padding = "=".repeat((4 - (b64.length % 4)) % 4);
  const normalized = (b64 + padding).replace(/-/g, "+").replace(/_/g, "/");
  const raw = typeof atob === "function" ? atob(normalized) : Buffer.from(normalized, "base64").toString("binary");
  const out = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i);
  return out;
}
