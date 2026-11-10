# Dependency license report

Generated 2026-11-10 from pubspec.lock (158 packages). Re-run: `node tool/license_scan.js`.

| License | Packages |
|---|---|
| MIT | 39 |
| BSD | 92 |
| Apache-2.0 | 10 |
| MPL-2.0 | 2 |
| sdk | 5 |
| LGPL | 1 |
| SYNCFUSION-COMMERCIAL | 9 |

## Needs a decision before selling (closed source)

| Package | Version | Type | License | Recommendation |
|---|---|---|---|---|
| dbus | 0.7.15 | transitive | MPL-2.0 | Linux-only transitive (network info). OK unmodified; keep the notice. |
| flutter_esc_pos_utils | 1.0.1 | direct main | LGPL | Thermal-printer ESC/POS encoder. LGPL static-linking duties are hard to meet in Flutter. Proposed: replace with an MIT/BSD encoder or a small in-house encoder. **Not done — owner decision.** |
| nm | 0.5.0 | transitive | MPL-2.0 | Linux-only transitive (network info). OK unmodified; keep the notice. |
| syncfusion_flutter_core | 30.2.7 | transitive | SYNCFUSION-COMMERCIAL | Commercial licence required (or Syncfusion Community Licence if eligible). Proposed: replace the PDF viewer with printing's PdfPreview. **Not done — owner decision.** |
| syncfusion_flutter_pdf | 30.2.7 | transitive | SYNCFUSION-COMMERCIAL | Commercial licence required (or Syncfusion Community Licence if eligible). Proposed: replace the PDF viewer with printing's PdfPreview. **Not done — owner decision.** |
| syncfusion_flutter_pdfviewer | 30.2.7 | direct main | SYNCFUSION-COMMERCIAL | Commercial licence required (or Syncfusion Community Licence if eligible). Proposed: replace the PDF viewer with printing's PdfPreview. **Not done — owner decision.** |
| syncfusion_flutter_signaturepad | 30.2.7 | transitive | SYNCFUSION-COMMERCIAL | Commercial licence required (or Syncfusion Community Licence if eligible). Proposed: replace the PDF viewer with printing's PdfPreview. **Not done — owner decision.** |
| syncfusion_pdfviewer_linux | 30.2.7 | transitive | SYNCFUSION-COMMERCIAL | Commercial licence required (or Syncfusion Community Licence if eligible). Proposed: replace the PDF viewer with printing's PdfPreview. **Not done — owner decision.** |
| syncfusion_pdfviewer_macos | 30.2.7 | transitive | SYNCFUSION-COMMERCIAL | Commercial licence required (or Syncfusion Community Licence if eligible). Proposed: replace the PDF viewer with printing's PdfPreview. **Not done — owner decision.** |
| syncfusion_pdfviewer_platform_interface | 30.2.7 | transitive | SYNCFUSION-COMMERCIAL | Commercial licence required (or Syncfusion Community Licence if eligible). Proposed: replace the PDF viewer with printing's PdfPreview. **Not done — owner decision.** |
| syncfusion_pdfviewer_web | 30.2.7 | transitive | SYNCFUSION-COMMERCIAL | Commercial licence required (or Syncfusion Community Licence if eligible). Proposed: replace the PDF viewer with printing's PdfPreview. **Not done — owner decision.** |
| syncfusion_pdfviewer_windows | 30.2.7 | transitive | SYNCFUSION-COMMERCIAL | Commercial licence required (or Syncfusion Community Licence if eligible). Proposed: replace the PDF viewer with printing's PdfPreview. **Not done — owner decision.** |

## Resolved

- **fuzzywuzzy (GPL-2.0)** was used for help search. It is replaced by an independent implementation (`lib/services/help_search/fuzzy_score.dart`) and removed from pubspec.yaml.
