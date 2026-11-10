// Portable crypto (WebCrypto only): runs on Node 22+ and Cloudflare Workers.
// Must stay byte-compatible with lib/licensing/license_codec.dart and
// lib/utils/reset_code_verifier.dart.

const enc = new TextEncoder();
const subtle = globalThis.crypto.subtle;

export const b64url = (bytes) =>
  btoa(String.fromCharCode(...new Uint8Array(bytes)))
    .replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
export const unb64url = (s) => {
  const t = s.replaceAll('-', '+').replaceAll('_', '/');
  const bin = atob(t + '='.repeat((4 - (t.length % 4)) % 4));
  return Uint8Array.from(bin, (c) => c.charCodeAt(0));
};
export const b64 = (bytes) => btoa(String.fromCharCode(...new Uint8Array(bytes)));
export const unb64 = (s) => Uint8Array.from(atob(s), (c) => c.charCodeAt(0));

/** Signing key from a 32-byte seed + its public key (the .secrets JSON format). */
export async function importSigningKey({ seed, public: pub }) {
  return subtle.importKey(
    'jwk',
    { kty: 'OKP', crv: 'Ed25519', d: b64url(unb64(seed)), x: b64url(unb64(pub)) },
    { name: 'Ed25519' },
    false,
    ['sign'],
  );
}

export async function importVerifyKey(pubBytes) {
  return subtle.importKey('raw', pubBytes, { name: 'Ed25519' }, false, ['verify']);
}

/** New key pair in the .secrets JSON format. */
export async function newKeyFile() {
  const pair = await subtle.generateKey({ name: 'Ed25519' }, true, ['sign', 'verify']);
  const jwk = await subtle.exportKey('jwk', pair.privateKey);
  return {
    algorithm: 'Ed25519',
    created: new Date().toISOString(),
    seed: b64(unb64url(jwk.d)),
    public: b64(unb64url(jwk.x)),
  };
}

export const PLANS = {
  '6m': { days: 183, label: '6 months' },
  '1y': { days: 365, label: '1 year' },
  life: { days: null, label: 'Lifetime' },
};

/** YYYY-MM-DD (UTC) */
export const isoDate = (d) => new Date(d).toISOString().slice(0, 10);

export function addDays(dateStr, days) {
  const d = new Date(`${dateStr}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() + days);
  return isoDate(d);
}

/**
 * Signed licence key: CV1.<base64url(json)>.<base64url(sig)>, signature over
 * "CVLIC1|" + body. Payload fields match LicensePayload.toJson().
 */
export async function signLicence(signingKey, { id, name, email, plan, issued, expires, device }) {
  const payload = { v: 1, id, n: name, e: email || '', p: plan, i: issued, x: expires ?? null, d: device };
  const body = b64url(enc.encode(JSON.stringify(payload)));
  const sig = await subtle.sign({ name: 'Ed25519' }, signingKey, enc.encode(`CVLIC1|${body}`));
  return `CV1.${body}.${b64url(sig)}`;
}

/** Returns the payload if [key] is validly signed, else null. */
export async function verifyLicence(verifyKey, key) {
  const parts = key.replace(/\s+/g, '').split('.');
  if (parts.length !== 3 || parts[0] !== 'CV1') return null;
  try {
    const ok = await subtle.verify({ name: 'Ed25519' }, verifyKey, unb64url(parts[2]), enc.encode(`CVLIC1|${parts[1]}`));
    return ok ? JSON.parse(new TextDecoder().decode(unb64url(parts[1]))) : null;
  } catch {
    return null;
  }
}

/** Admin password reset code: base64 Ed25519 signature of "<installationId>:<utcDay>". */
export async function signResetCode(resetKey, installationId, now = Date.now()) {
  const bucket = Math.floor(now / 86400000);
  const sig = await subtle.sign({ name: 'Ed25519' }, resetKey, enc.encode(`${installationId.trim()}:${bucket}`));
  return b64(sig);
}

/** Signed status for the (future) online licence check. */
export async function signStatus(signingKey, status) {
  const body = b64url(enc.encode(JSON.stringify(status)));
  const sig = await subtle.sign({ name: 'Ed25519' }, signingKey, enc.encode(`CVSTAT1|${body}`));
  return { body, sig: b64url(sig) };
}

/** Device code as typed by a customer -> canonical XXXX-XXXX-XXXX-XXXX. */
export function normalizeDevice(code) {
  const c = code.toUpperCase().replace(/[\s-]/g, '').replaceAll('O', '0').replace(/[IL]/g, '1');
  if (!/^[0-9A-HJKMNP-TV-Z]{16}$/.test(c)) return null;
  return c.match(/.{4}/g).join('-');
}

// Admin password: PBKDF2-SHA256 (portable; Workers cap iterations at 100k).
const ITER = 100000;
export async function hashPassword(password, saltB64) {
  const salt = saltB64 ? unb64(saltB64) : crypto.getRandomValues(new Uint8Array(16));
  const key = await subtle.importKey('raw', enc.encode(password), 'PBKDF2', false, ['deriveBits']);
  const bits = await subtle.deriveBits({ name: 'PBKDF2', hash: 'SHA-256', salt, iterations: ITER }, key, 256);
  return `pbkdf2$${ITER}$${b64(salt)}$${b64(bits)}`;
}
export async function checkPassword(password, stored) {
  const [, , salt, hash] = (stored || '').split('$');
  if (!salt) return false;
  const again = (await hashPassword(password, salt)).split('$')[3];
  if (again.length !== hash.length) return false;
  let diff = 0;
  for (let i = 0; i < again.length; i++) diff |= again.charCodeAt(i) ^ hash.charCodeAt(i);
  return diff === 0;
}

export const randomToken = () => b64url(crypto.getRandomValues(new Uint8Array(24)));
