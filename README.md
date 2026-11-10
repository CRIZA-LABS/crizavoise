<div align="center">
  <img src="assets/brand/lockup-light.png" alt="CrizaVoise" height="64" />

  <p><strong>CrizaVoise by Criza Labs</strong> — simple, offline invoicing and billing for small businesses.</p>
  <p>Windows · Linux · macOS</p>
  <p><strong>Free and open source</strong> · <a href="LICENSE">Apache License 2.0</a> · <a href="https://criza.dev">criza.dev</a></p>
</div>

---

> **Free and open source.** © 2026 Criza Labs. Licensed under the [Apache License 2.0](LICENSE): use it, change it and share it, for personal or commercial work.
> **If you fork or redistribute it, give credit:** keep [LICENSE](LICENSE) and [NOTICE](NOTICE), and show **"Based on CrizaVoise by Criza Labs (https://criza.dev)"** in your README and About screen. Use your own name and logo ([TRADEMARKS.md](TRADEMARKS.md)).

## What it does
- **Bills in seconds:** a "Quick bill" for walk-in customers, product quick codes (type `R5` + Enter), product photos, and voice typing.
- **Documents:** PDF invoices, quotations, receipts and credit/debit notes. Several templates in CrizaVoise colours, with your logo (any size), signature and watermark. Thermal receipts too.
- **GST-ready:** GSTIN, HSN/SAC, per-item or global tax, a UPI QR code, and custom invoice numbers with an audit trail.
- **Getting paid:** share an invoice on WhatsApp, send payment reminders by WhatsApp or SMS, and track payments, the cash/UPI ledger and reports (CSV/PDF).
- **Stock and suppliers:** customers, products, stock, purchase bills, suppliers and returns.
- **Team and security:** multiple companies, admin and standard users, quick PIN sign-in, recovery codes and session timeout.
- **For everyone:** 8 languages, including Hindi and Gujarati; read-aloud; large number pad; reduce motion; and screen-reader labels.
- **Free:** no trial, no subscription, no licence key, no ads.
- **100% offline:** data stays in a local SQLite database, with built-in backup and restore. No tracking.

## Screenshots
| Dashboard (light) | Dashboard (dark) |
|---|---|
| ![Dashboard](docs/screenshots/dashboard_light.png) | ![Dashboard, dark](docs/screenshots/dashboard_dark.png) |
| **New invoice** | **Invoices** |
| ![New invoice](docs/screenshots/new_invoice_light.png) | ![Invoices](docs/screenshots/invoices_light.png) |
| **Products (dark)** | **First run: create your account** |
| ![Products](docs/screenshots/products_dark.png) | ![Create account](docs/screenshots/create_account_light.png) |

Regenerate them with `SCREENSHOTS=1 flutter test test/screenshots/app_screenshots_test.dart` (written to `build/screenshots`).

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
ISCC.exe installer.iss        # → dist/CrizaVoise-Setup-1.0.0.exe (Inno Setup 6)
dart run flutter_launcher_icons   # after changing assets/brand/icons/icon-1024.png
```

**Where data lives**
- Windows: `%APPDATA%\Criza Labs\CrizaVoise\`
- Linux: `~/.local/share/dev.criza.crizavoise/`
- macOS: `~/Library/Application Support/dev.criza.crizavoise/`

**More docs**
- Brand guidelines: [docs/brand.md](docs/brand.md)
- Optional licence-key system (switched off; `AppConfig.licensingEnabled`): [docs/licensing.md](docs/licensing.md), [tool/license-admin](tool/license-admin/README.md)
- Performance baseline: [docs/performance.md](docs/performance.md)
- Design tokens: `lib/theme/tokens.dart`
- Contributor and AI-session notes: [CLAUDE.md](CLAUDE.md)

## Contributing
Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License and credit
CrizaVoise is licensed under the [Apache License 2.0](LICENSE). Under that licence, anyone who redistributes this code or a version based on it must keep the [NOTICE](NOTICE) file. We ask that forks show this line in their README and About screen:

> Based on CrizaVoise by Criza Labs (https://criza.dev)

The CrizaVoise and Criza Labs names and logos are not covered by the code licence. See [TRADEMARKS.md](TRADEMARKS.md).

CrizaVoise started from [Invoiso](https://github.com/Anooppandikashala/invoiso) (MIT). Its notice and every other third-party licence are in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) and in the app under **Settings → About → Open-source licenses**.

## Credits
Made by **Criza Labs** — https://criza.dev. Need a custom build or help for your business? Write to connect@criza.dev.
