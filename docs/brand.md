# CrizaVoise brand sheet

**CrizaVoise by Criza Labs**: simple invoicing for small businesses. Parent brand: Criza Labs (https://criza.dev).
Assets live in `assets/brand/` (app) and `docs/brand/` (copies plus previews). Preview sheets: `docs/brand/size-test.png` and `docs/brand/lockups.png`.

## 1. Brand architecture: an endorsed product
CrizaVoise has its own name and mark, endorsed by Criza Labs. It borrows the parent's **core cues**:
- the red and blue ribbons,
- the deep navy,
- the angled cuts,
- the Bricolage and Inter typefaces.

The endorsement line **"BY CRIZA LABS"** sits under the wordmark in the full lockup.

## 2. Name
- Write **CrizaVoise**: one word, with a capital C and a capital V. Never "Crizavoise", "Criza Voise" or "CRIZAVOISE" in running text.
- Lowercase `crizavoise` is only for technical IDs (package, binary, bundle ID `dev.criza.crizavoise`).
- **Credit lines:** "CrizaVoise by Criza Labs". On invoices: "Powered by CrizaVoise · criza.dev".
- Never say or imply Criza Labs created the original codebase. Third-party origins are in `THIRD_PARTY_NOTICES.md`.
- Criza Labs isn't a registered company, so don't add "Ltd", "Pvt Ltd", "LLP" or "Inc.".

## 3. The mark: "Ribbon V"
A **V built from two ribbons**: a short **red** arm and a long **blue** arm. The blue arm folds over the red at the base, with a touch of Criza magenta at the seam. It sits on the **Criza navy** plate.

| It reads as… | Because… |
|---|---|
| **V** for Voise | the letterform itself |
| **✓ paid / done** | the asymmetric arms give a check-mark silhouette |
| **Part of Criza Labs** | it's the Criza "A" (a folded red ribbon, Λ) turned upside down, with horizontal cuts like the A's feet; red over blue with a magenta seam, like the Criza "C" |

**Construction** (on a 64-unit grid; the generator lives in the brand script):
- Ribbon thickness 9.6. Mitred vertex. **Both tips are cut horizontally.**
- The V fills about 66% of the plate width, optically centred (nudged 1 unit down).
- Plate radius 14/64 (22%), with a top-to-bottom navy gradient and a 1-unit inner hairline at 8% white.
- Below 48 px, use `mark-small.svg`. The seam is dropped and the silhouette stays the same.

### Files
| File | Use |
|---|---|
| `mark.svg` | App icon / avatar at 48 px and up |
| `mark-small.svg` | 16–47 px: favicon, title bar, tray, taskbar |
| `symbol.svg` | The Ribbon V without the plate, on any background with enough contrast |
| `mark-mono.svg`, `symbol-mono.svg` | One colour (`currentColor`): thermal receipts, print, embossing |
| `wordmark-light/dark/mono.svg` | Name only |
| `lockup-light/dark.svg` | **Primary lockup:** mark + wordmark + "BY CRIZA LABS". Min height **48 px** |
| `lockup-compact-light/dark.svg` | Mark + wordmark, for headers under 48 px (e.g. the 32 px sidebar) |
| `icons/icon-1024.png` | Master for store, macOS, iOS and Android icons |
| `windows/runner/resources/app_icon.ico` | 14 sizes (16, 20, 24, 30, 32, 36, 40, 48, 60, 64, 72, 80, 96, 256), per Microsoft's target-size list |

### Do
- Keep clear space equal to the ribbon thickness (≈ 15% of the mark's height) on all sides.
- Use the **plated** mark wherever it might land on an unknown background (taskbar, store, favicon).
- Use the light lockup on paper or white, and the dark lockup on navy or black.

### Don't
- Recolour the ribbons (red is always the short arm, blue the long arm).
- Swap the fold so red is on top.
- Round the cut tips, add outlines or drop shadows, or rotate or stretch the mark.
- Set "CrizaVoise" in another typeface in place of the wordmark.
- Put the unplated symbol on mid-tone or busy backgrounds.

## 4. Wordmark
- "Criza" + "Voise" in **Bricolage Grotesque, weight 760, tracking −2.5%**, outlined to paths.
- "Criza" uses the ink colour. "Voise" uses the **app primary blue**, which links the name to the blue ribbon and passes AA as text: `#0a5ea8` on light, `#5cc0ff` on dark.
- Endorsement: "BY CRIZA LABS" in **Inter SemiBold**, +16% tracking, 30% of cap height, muted ink.
- No gradients on text. Gradients lose legibility at small sizes and fail contrast checks.

## 5. Colour
**Logo colours**
| Role | Hex |
|---|---|
| Plate navy (bottom → top) | `#071426` → `#122a4c` |
| Red ribbon (tip → fold) | `#ff5a3c` → `#e2231a` → `#a5121b` |
| Blue ribbon (tip → fold) | `#3cc8ff` → `#0a8ef0` → `#0a4fb3` |
| Seam accent | `#f51e91` (Criza magenta, seam only) |

**UI tokens** (`lib/theme/tokens.dart`; all text pairs pass WCAG AA, enforced by `test/theme_contrast_test.dart`)
| Token | Dark | Light |
|---|---|---|
| Background | `#08090d` | `#f4efe6` |
| Surface 1 / 2 / 3 | `#0e1016` / `#13151d` / `#1c1f2a` | `#fbf8f3` / `#ffffff` / `#ebe4d7` |
| Text | `#f6f2ea` | `#12131a` |
| Text muted | `#b3b7c2` | `#4a4e59` |
| Primary (actions, links, "Voise") | `#5cc0ff` | `#0a5ea8` |
| Accent | `#ff6b78` | `#c81e33` |
| Success / Warning / Danger / Info | `#3ddc97` / `#ffc857` / `#ff8a80` / `#5cc0ff` | `#17703f` / `#8a5300` / `#b3261e` / `#0a5ea8` |

**Gradients**
- **Ribbon gradient** (`CvBrand.ribbonGradient`): red → blue, for thin accent strokes and highlights only.
- **CTA gradient** (white text passes AA): `#d81f30` → `#c0157a` → `#0a6fc2`.

## 6. Typography
- **Bricolage Grotesque** for display text and headings (bold, slightly tight).
- **Inter** for everything else.
- Devanagari and Tibetan fall back to the bundled Noto fonts. All fonts are OFL-licensed (see `THIRD_PARTY_NOTICES.md`).

## 7. Voice
Plain, warm, short. Talk to a busy shop owner, not an accountant.
- Say "Send invoice", not "Initiate invoice dispatch".
- Lead with the action and use numbers people can check.
- No "leading", "world-class" or "cutting-edge".
- Errors say what happened and what to do next, never raw error text.

## 8. Why it's built this way (research notes, 2026-11-09)
| Practice | Source | How CrizaVoise applies it |
|---|---|---|
| Design for 16 px first; one bold silhouette; no fine detail | Logo/favicon guides (Piktochart, Zillion Designs, Inkbot) | A single V silhouette; seam dropped below 48 px |
| Simple, unambiguous, recognisable at every size; no text in the icon; don't fill the whole tile | Apple HIG (icons) | No letters inside the icon; the V fills about 66% of the plate |
| ICO at least 16/24/32/48/256; Windows picks the exact size or the next one up | Microsoft Learn: app icon construction | 14 sizes in the `.ico`, a pixel match at every Windows 11 scale step |
| Plated icons must handle light and dark themes themselves | Microsoft Learn | The navy plate plus an 8% white hairline separates it on both taskbars (see `size-test.png`) |
| Endorsed products share the parent's core cues and carry an endorsement line | Brand-architecture guides (MIT brand, Indorama brand book) | Criza ribbons, colours, cuts and type, plus "BY CRIZA LABS" |
| Mono and reversed versions; vector masters | Logo guides (Fiveable, Zenind) | `*-mono.svg`, light and dark lockups, everything SVG |
