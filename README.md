<div align="center">
  <img src="assets/brand/lockup-light.svg" alt="CrizaVoise" height="64" />

  <p><strong>CrizaVoise by Criza Labs</strong> — simple, offline invoicing and billing for small businesses.</p>
  <p>Windows · Linux · macOS</p>
</div>

---

> **Proprietary software.** © 2026 Criza Labs. All rights reserved. See [LICENSE](LICENSE).
> Portions are based on open-source software; their notices are in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) and in the app under **Settings → About → Open-source licenses**.

## What it does
- PDF invoices, quotations and receipts, with several templates, your logo, a signature and a watermark
- GST-ready: GSTIN, HSN/SAC, per-item or global tax, and a UPI QR code on invoices
- Customers, products, stock, purchase bills, suppliers, returns, and credit/debit notes
- Payments, cash/UPI ledger, cash-exchange services and reports (CSV/PDF)
- Multiple companies, users with admin/standard roles, and session timeout
- Thermal receipt printing, multi-currency, and 7 languages (more coming)
- 100% offline: data stays in a local SQLite database, with built-in backup and restore

<!-- Screenshots: add light + dark captures here (docs/screenshots/…) -->

## Development

| | |
|---|---|
| Stack | Flutter 3 (desktop), Riverpod, sqflite + sqflite_common_ffi, `pdf` + `printing`, ARB l10n |
| SDK | Flutter stable (3.47+) · on Windows: Visual Studio 2022 Build Tools (C++) and **Developer Mode** on |

```bash
flutter pub get
flutter gen-l10n              # after editing lib/l10n/*.arb
flutter analyze
flutter test
flutter run -d windows        # or linux / macos
flutter build windows         # → build/windows/x64/runner/Release/crizavoise.exe
dart run flutter_launcher_icons   # after changing assets/brand/icons/icon-1024.png
```

**Where data lives**
- Windows: `%APPDATA%\Criza Labs\CrizaVoise\`
- Linux: `~/.local/share/dev.criza.crizavoise/`
- macOS: `~/Library/Application Support/dev.criza.crizavoise/`

**More docs**
- Brand guidelines: [docs/brand.md](docs/brand.md)
- Design tokens: `lib/theme/tokens.dart`
- Contributor and AI-session notes: [CLAUDE.md](CLAUDE.md)

## Credits
Made by **Criza Labs** — https://criza.dev
