# Licensing (owner guide)

CrizaVoise is free for **30 days** on each computer, then needs a licence: **6 months**, **1 year** or **lifetime**. Everything works offline. There are no servers and no activation calls.

## How it works
- **Keys are signed** with Criza Labs' Ed25519 private key. The app holds only the public key (`lib/licensing/license_keys.dart`), so it can check keys but nobody can make them from the app.
- **A key carries** the licence number, name, email, plan, issue date, expiry and **device code**. Changing any character breaks the signature.
- **Device code:** a 16-character fingerprint of the computer's OS machine ID, e.g. `N1Z8-C0EC-YF0B-18FR`.
  - The customer copies it from **Settings → Licence**.
  - Reinstalling the app doesn't change it. Reinstalling Windows does.
- **The trial** starts on first launch. It is stored in three places: app settings, the data folder, and the Windows registry (HKCU).
  - The earliest start date wins, so deleting one place doesn't reset the trial.
  - The latest date seen is remembered, so setting the clock back doesn't add days.
- **When the trial or licence ends:**
  - View, print, share, export and backup keep working.
  - Saving invoices, quotations, receipts, notes and purchase bills shows "Activate CrizaVoise to save".
  - Data is never locked.
- **Reminders:** a banner shows in the last 7 days of the trial or of a dated licence.

Offline licensing can't stop a determined cracker. It keeps honest customers honest and makes casual sharing pointless, because a key works on one computer only.

## Your private keys (`.secrets/`)
- `license_signing_key.json` signs licence keys. `reset_signing_key.json` signs password-reset codes.
- **Back up `.secrets/` offline now** (two USB drives, or a password manager). If you lose it, you can't issue keys that the shipped app versions accept.
- `.secrets/` is gitignored and must never be committed, shared or bundled with the app.
- `.secrets/issued_licenses.csv` is your ledger of every key issued.

## Issuing a licence
The customer sends their device code (the "Buy or renew" button pre-fills an email to connect@ with it). After payment:

```bash
dart run tool/license/generate.dart license --plan 1y --name "Sharma Traders" \
    --email owner@sharma.in --device N1Z8-C0EC-YF0B-18FR --id CV-2026-0001
```

- Plans: `6m` (183 days), `1y` (365 days), `life`.
- Validity counts from today. Pass `--issued YYYY-MM-DD` to start it on another date, e.g. when a renewal continues from the old expiry.
- `--device "*"` makes a key that works on any computer. Use it only for special cases.
- Send the printed `CV1.…` key. The customer pastes it in **Settings → Licence → Activate**.
- `dart run tool/license/generate.dart verify <key>` shows what a key contains.

**New computer?** Issue a new key for the new device code. The customer can remove the old one under **Settings → Licence → Remove licence from this computer**.

## Password reset codes (customer lost both password and recovery code)
1. The customer clicks **Forgot password → Get a code from Criza Labs** and emails you the installation ID.
2. Verify that they own the business.
3. Run `dart run tool/license/generate.dart reset --installation <id>` and send the code. It's valid for about 3 days, on that installation only.

## Changing the keys
`init --force` makes new keys, and every key already issued stops working in new builds. Don't, unless a private key has leaked.
