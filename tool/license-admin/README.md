# CrizaVoise licence admin (Criza Labs internal)

A small private web app for running CrizaVoise licences. It covers:
- customers
- issuing 6-month, 1-year and lifetime keys
- renewals
- moving a licence to a new PC
- revoking
- password reset codes
- key rotation
- an activity log and CSV export

It runs **only on your computer** at http://127.0.0.1:8787. Nothing is reachable from the internet.

## Start
```bash
cd tool/license-admin
npm install        # once
npm start          # then open http://127.0.0.1:8787
```
On first start, choose an admin password (12+ characters).

## Where things live
- **Signing keys:** `<repo>/.secrets/license_signing_key.json` and `reset_signing_key.json`. These are the same keys `tool/license/generate.dart` uses.
- **Admin database:** `<repo>/.secrets/admin/licences.db` holds customers, licences, reset codes and the activity log.
- **Backups:** `.secrets/` is gitignored. Back up the whole folder offline (two USB drives, or an encrypted cloud drive).

Override the folders with `CV_SECRETS_DIR` / `CV_ADMIN_DATA`, and the port with `PORT`.

## Everyday tasks
| Task | Where |
|---|---|
| New sale | Customers → New customer → Issue licence. Then copy the key, or press **Open WhatsApp** / **Email** to send the ready-made message. |
| Renewal | Open the licence → **Renew**. It continues from the old end date if that's still in the future. |
| Customer changed PC | Open the licence → **Move to a new PC** with the new device code. It keeps the same plan and end date, and the old licence is marked *moved*. |
| Refund / misuse | Open the licence → **Revoke** (recorded). |
| Locked out (no password, no recovery code) | **Reset codes**: paste the installation ID from the customer's Forgot password screen. Verify it's really the owner first. |
| Is this key real? | **Check a key**. |
| Key leaked | **Keys → Rotate**, rebuild the app, then **Re-issue** and send the new keys. |

Keys from this app and from `dart run tool/license/generate.dart` are identical in format; the test suite checks both.

## Hosting later on Cloudflare (criza.dev subdomain)
The code is written to move unchanged:
- **Web framework:** Hono runs on Workers.
- **Crypto:** WebCrypto Ed25519 is supported on Workers.
- **Database:** the SQL works on D1, and `d1Db()` in `src/db.mjs` is the adapter.

Steps when you decide to:
1. Create a D1 database and run `SCHEMA` from `src/db.mjs`.
2. Add a Worker entry that calls `createApp({ db: d1Db(env.DB), keys, canRotate: false })`. `keys` should read the two key JSONs from Worker secrets.
3. Put `licences.criza.dev` behind **Cloudflare Access** so only your email can sign in. The admin password stays as a second lock.
4. Only `/api/v1/status` (the online licence check) should bypass Access.

**Risk:** once hosted, the private signing key lives in Cloudflare secrets. Turn on 2FA for the Cloudflare account.

## Online licence check (dormant)
`GET /api/v1/status?id=CV-2026-0001&device=XXXX-...` returns a status signed with the licence key: active, expiring, expired, revoked, moved, renewed or other-device. The app has a matching client, but it is off until a hosted URL is set in `AppConfig.licenseCheckUrl`.

## Tests
`npm test`
