# CrizaVoise brand sheet

**CrizaVoise by Criza Labs** — simple invoicing for small businesses. Parent brand: Criza Labs (https://criza.dev). The source files for every asset below are in `assets/brand/` and `docs/brand/`.

## Name
- Write **CrizaVoise**: one word, with a capital C and a capital V. Never "Crizavoise", "Criza Voise" or "CRIZAVOISE" in running text.
- Lowercase "crizavoise" is only for technical identifiers (package name, binary, bundle ID `dev.criza.crizavoise`).
- The credit line is **"CrizaVoise by Criza Labs"**. The short credit on invoices is **"Powered by CrizaVoise · criza.dev"**.
- Never say or imply that Criza Labs created the original codebase. Third-party origins are credited in `THIRD_PARTY_NOTICES.md`.
- Criza Labs is not a registered company, so don't add "Ltd", "Pvt Ltd", "LLP" or "Inc.".

## Logo
| File | Use |
|---|---|
| `mark.svg` | App icon, favicon, splash, small spaces (below 32px tall, use the mark alone) |
| `mark-mono.svg` | One-colour print, thermal receipts, watermarks (`currentColor`) |
| `wordmark-light.svg` / `wordmark-dark.svg` | Headers on light / dark backgrounds |
| `wordmark-mono.svg` | One-colour contexts |
| `lockup-light.svg` / `lockup-dark.svg` | Mark + wordmark together: About screen, splash, OG image |

**The mark:** a rounded tile in the Criza gradient, holding a white invoice sheet with a folded corner. The check stroke on the sheet is also the "V" of Voise.

**Do**
- Keep clear space equal to the fold-corner size (about 1/6 of the mark) on every side.
- Use the light lockup on paper `#f4efe6` or white, and the dark one on `#08090d`–`#1c1f2a`.

**Don't**
- Recolour, stretch or rotate the logo, or add shadows or outlines.
- Put the gradient wordmark on busy photos.
- Set "CrizaVoise" in a different font in place of the logo.

## Colour
Taken from the Criza Labs site (`src/styles/tokens.css`). The app tokens live in `lib/theme/tokens.dart`.

| Token | Dark | Light |
|---|---|---|
| Background | `#08090d` | `#f4efe6` |
| Surface 1 / 2 / 3 | `#0e1016` / `#13151d` / `#1c1f2a` | `#fbf8f3` / `#ffffff` / `#ebe4d7` |
| Text | `#f6f2ea` | `#12131a` |
| Text muted | `#b3b7c2` | `#4a4e59` |
| Primary (actions, links) | `#5cc0ff` | `#0a5ea8` |
| Accent | `#ff6b78` | `#c81e33` |
| Success / Warning / Danger / Info | `#3ddc97` / `#ffc857` / `#ff8a80` / `#5cc0ff` | `#17703f` / `#8a5300` / `#b3261e` / `#0a5ea8` |

- **Brand gradient:** red `#fd352a` → pink `#f51e91` (45%) → blue `#019ffb`. Use it for the logo and accents only, never behind body text.
- **CTA gradient** (white text passes AA): `#d81f30` → `#c0157a` → `#0a6fc2`.

## Typography
- **Bricolage Grotesque** for display text and headings (bold, slightly tight tracking).
- **Inter** for everything else.
- Devanagari and Tibetan fall back to the bundled Noto fonts.
- Both brand fonts are under the SIL Open Font License (see `THIRD_PARTY_NOTICES.md`).

## Voice
Plain, warm, short. Talk to a busy shop owner, not an accountant.
- Say "Send invoice", not "Initiate invoice dispatch".
- Lead with the action and use numbers people can check.
- No "leading", "world-class" or "cutting-edge".
- Errors say what happened and what to do next, never raw error text.
