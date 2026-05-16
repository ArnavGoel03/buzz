import crypto from "node:crypto";
import { promises as dns } from "node:dns";

/** Refuse open-redirects: only same-origin paths starting with a single "/". */
export function safeRelativePath(next: unknown, fallback = "/"): string {
  if (typeof next !== "string") return fallback;
  if (!next.startsWith("/")) return fallback;
  if (next.startsWith("//") || next.startsWith("/\\")) return fallback;
  // Reject control chars / NUL bytes that some HTTP stacks truncate on.
  if (/[\x00-\x1f\x7f]/.test(next)) return fallback;
  // Reject percent-encoded backslashes / slashes that re-introduce protocol-relative URLs
  // after the browser performs a decode pass on the Location header.
  if (/%5c%5c|%2f%2f/i.test(next)) return fallback;
  return next;
}

/**
 * Escape a value for safe embedding inside <script type="application/ld+json">.
 * U+2028 / U+2029 are legal in JSON but illegal in JS string literals; we encode
 * them along with the closing-tag chars via RegExp-constructor patterns (so this
 * source file doesn't itself contain raw line/para separators).
 */
const SEP_2028 = new RegExp(String.fromCharCode(0x2028), "g");
const SEP_2029 = new RegExp(String.fromCharCode(0x2029), "g");
export function safeJsonLd(value: unknown): string {
  return JSON.stringify(value)
    .replace(/</g, "\\u003c")
    .replace(/>/g, "\\u003e")
    .replace(/&/g, "\\u0026")
    // Also escape `/` so an embedded `</script>` cannot terminate the tag in legacy
    // parsing modes — matches React's `htmlEscapeJsonString` behaviour.
    .replace(/\//g, "\\u002f")
    .replace(SEP_2028, "\\u2028")
    .replace(SEP_2029, "\\u2029");
}

/** Constant-time HMAC compare; returns false on length mismatch instead of throwing. */
export function timingSafeHmacEqual(a: string, b: string): boolean {
  const ab = Buffer.from(a, "hex");
  const bb = Buffer.from(b, "hex");
  if (ab.length === 0 || ab.length !== bb.length) return false;
  return crypto.timingSafeEqual(ab, bb);
}

export function verifyMailgunSignature(
  timestamp: string | undefined,
  token: string | undefined,
  signature: string | undefined,
  signingKey: string
): boolean {
  if (!timestamp || !token || !signature) return false;
  const expected = crypto
    .createHmac("sha256", signingKey)
    .update(timestamp + token)
    .digest("hex");
  try { return timingSafeHmacEqual(expected, signature); } catch { return false; }
}

/** Shared-secret header check used by Supabase database-webhook callers. */
export function verifySharedSecret(req: Request, envVar: string): boolean {
  const expected = process.env[envVar];
  if (!expected) return false;
  const header = envVar.toLowerCase().replace(/_/g, "-");
  // Bearer fallback removed — callers had to know the exact header anyway, and the
  // `Authorization` header is routinely logged by CDNs/proxies, leaking the secret.
  const got = req.headers.get(header);
  if (typeof got !== "string" || got.length !== expected.length) return false;
  try {
    return crypto.timingSafeEqual(Buffer.from(got), Buffer.from(expected));
  } catch { return false; }
}

/**
 * SSRF guard for outbound fetches of caller-supplied URLs (calendar import, webhook relay).
 * Rejects non-HTTPS schemes, RFC1918/loopback/link-local/IPv6-ULA hosts, and `.internal` /
 * `.local` suffixes. Resolves DNS so an attacker can't smuggle 169.254.169.254 behind a
 * public-looking hostname.
 */
export async function assertPublicHttpsUrl(raw: string): Promise<URL> {
  let url: URL;
  try { url = new URL(raw); } catch { throw new Error("invalid_url"); }
  if (url.protocol !== "https:") throw new Error("scheme_not_https");
  let host = url.hostname.toLowerCase();

  // Reject `.internal` / `.local` / bare loopback hostnames.
  if (host.endsWith(".internal") || host.endsWith(".local") ||
      host.endsWith(".internal.") || host.endsWith(".local.") ||
      host === "localhost" || host === "metadata.google.internal") {
    throw new Error("blocked_host");
  }

  // Reject decimal-encoded (`https://3232235521/` = 192.168.0.1) and
  // hex-encoded (`https://0x7f000001/`) IPv4 literals before DNS resolution.
  if (/^\d+$/.test(host) || /^0x[0-9a-f]+$/.test(host) || /^(0[0-7]+\.){3,}/.test(host)) {
    throw new Error("blocked_host");
  }

  // Strip IPv6 brackets + zone-IDs before running the private-IP check, otherwise
  // `[fe80::1%eth0]` always falls through the `startsWith("fe80:")` test below.
  if (host.startsWith("[") && host.endsWith("]")) {
    host = host.slice(1, -1).split("%")[0];
    // After bracket-strip, treat as raw IPv6 and check immediately.
    if (isPrivateIp(host, 6)) throw new Error("private_ip");
  }

  const addrs = await dns.lookup(host, { all: true }).catch(() => []);
  for (const { address, family } of addrs) {
    if (isPrivateIp(address, family)) throw new Error("private_ip");
  }
  return url;
}

function isPrivateIp(ip: string, family: number): boolean {
  if (family === 4) {
    const p = ip.split(".").map((n) => parseInt(n, 10));
    if (p[0] === 10) return true;
    if (p[0] === 127) return true;
    if (p[0] === 169 && p[1] === 254) return true;
    if (p[0] === 172 && p[1] >= 16 && p[1] <= 31) return true;
    if (p[0] === 192 && p[1] === 168) return true;
    if (p[0] === 100 && p[1] >= 64 && p[1] <= 127) return true;
    if (p[0] === 0) return true;
    return false;
  }
  if (family === 6) {
    const lower = ip.toLowerCase();
    if (lower === "::1") return true;
    if (lower.startsWith("fe80:")) return true;
    if (lower.startsWith("fc") || lower.startsWith("fd")) return true;
    if (lower.startsWith("::ffff:")) return isPrivateIp(lower.slice(7), 4);
    return false;
  }
  return false;
}
