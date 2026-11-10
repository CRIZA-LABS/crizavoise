# Changelog

## 1.0.0 — unreleased (in development)

First release of **CrizaVoise by Criza Labs**.

### Identity
- New name, app ID (`dev.criza.crizavoise`), proprietary licence, Terms of Use and Privacy Policy (accepted on first launch).
- Brand "Ink · Paper · Stamp" (no blue). The app icon is a bill being printed, with dark and light versions. The full logo is "CRIZA VOISE.", built like the Criza Labs logo.
- Light and dark themes from one token set. All text passes WCAG AA, enforced by tests.
- Existing data is moved automatically from the old install (backup zip, copy, verified open, then the old folder is removed).

### New
- **Free 30-day trial, then a licence** (6 months, 1 year or lifetime), fully offline. Licence keys are signed by Criza Labs and tied to one computer. When a trial or licence ends, everything stays viewable, printable and exportable; only saving new documents waits for activation. Reminder banner in the last 7 days. See Settings → Licence.
- **Create your account** on first run: owners choose their own username and password. The built-in default login is no longer shown.
- **Recovery codes.** Each admin gets a one-time recovery code to reset a forgotten password offline. Existing admins are offered one at sign-in.
- **Forgot password** has two ways back in: your recovery code, or a one-time code from Criza Labs support. The old reset key from the original project no longer works.
- **Custom invoice numbers.** Off by default; an admin chooses who may use them. Numbers are unique and follow the GST format (16 characters max). Changing an existing number is admin-only, needs a reason and a password, and is recorded in an audit trail.
- **Product quick codes** (e.g. `R5`, `101`). Type the code and press Enter to add the product. Codes are searchable everywhere and included in CSV import/export.
- **Share on WhatsApp.** Saves the PDF, opens the customer's chat with a ready message (including your UPI ID), and shows a step-by-step guide.
- **Read aloud.** Invoices and totals can be spoken, in Indian English, Hindi or Gujarati voices where installed.
- **Gujarati** language, with Gujarati fonts on screen and in PDFs.
- **Reduce motion** setting (the computer's setting is also respected).
- **Logos of any size.** Logos, signatures and watermarks are resized automatically, with advice on the best size.

### Improved
- Navigation: 5 main items plus "More"; nothing removed.
- Consistent banners, stat tiles, cards and status colours across screens. Toggles are clearly visible when on.
- Help search, the PDF viewer and the receipt-printer encoder no longer use GPL, LGPL or commercial libraries; every dependency is MIT, BSD, Apache or MPL.
- No network calls: the update check, analytics, remote FAQ and donation links were removed.

### Known issues
- Gujarati and Hindi conjunct letters may not join correctly in PDFs (a limitation of the PDF library); check a real invoice.
- "Rs." stays the default for Indian rupees; ₹ can be chosen for new documents in Invoice settings.
- The app is unsigned, so Windows Smart App Control blocks it until it's code-signed.
