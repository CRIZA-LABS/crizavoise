# Dependency license report

Updated 2026-11-10 from pubspec.lock. Re-run with `node tool/license_scan.js`.

| License | Packages |
|---|---|
| BSD | 88 |
| MIT | 40 |
| Apache-2.0 | 10 |
| MPL-2.0 | 2 (dbus, nm: Linux only, used unmodified; noted in THIRD_PARTY_NOTICES.md) |
| Flutter/Dart SDK | 5 |

**No commercial, GPL or LGPL dependencies.** All of them are compatible with the project's Apache-2.0 licence.

## Resolved
- **fuzzywuzzy (GPL-2.0):** replaced by our own `lib/services/help_search/fuzzy_score.dart`.
- **syncfusion_flutter_pdfviewer (commercial licence):** replaced by `PdfBytesViewer`, which uses `printing`'s PdfPreview (Apache-2.0).
- **flutter_esc_pos_utils (LGPL):** replaced by our own `lib/services/escpos/esc_pos_encoder.dart`. It also no longer sends the "Cancel Kanji" byte pair that caused stray dots on some printers.
