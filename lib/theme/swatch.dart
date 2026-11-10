import 'package:flutter/painting.dart';

/// Compile-time-constant status colours for places that can't read the theme
/// (const constructors, static styles). Every colour in the UI must MEAN
/// something — CrizaVoise has no decorative rainbow:
///
///  * [neutral] — icons, chips and highlights with no status meaning
///  * [success] — paid, saved, in stock
///  * [warning] — due soon, low stock, needs attention
///  * [danger]  — overdue, out of stock, delete, errors (always with an icon)
///  * [stamp]   — the brand accent (Stamp red); prefer `colorScheme.primary`
///
/// Each comes in three strengths: the plain colour (icons/text), `…Soft`
/// (borders, 28% alpha) and `…Tint` (backgrounds, 12% alpha). The tones are
/// mid-tones chosen to stay legible on both Paper (light) and Ink (dark).
/// Prefer `Theme.of(context).colorScheme` / `CrizaTokens.of(context)` where a
/// BuildContext is available.
class CvSwatch {
  static const neutral = Color(0xFF63666E);
  static const neutralSoft = Color(0x4763666E);
  static const neutralTint = Color(0x1F63666E);

  static const success = Color(0xFF1A7D4C);
  static const successSoft = Color(0x471A7D4C);
  static const successTint = Color(0x1F1A7D4C);

  static const warning = Color(0xFFA86400);
  static const warningSoft = Color(0x47A86400);
  static const warningTint = Color(0x1FA86400);

  static const danger = Color(0xFFC9302A);
  static const dangerSoft = Color(0x47C9302A);
  static const dangerTint = Color(0x1FC9302A);

  static const stamp = Color(0xFFC8231C);
  static const stampSoft = Color(0x47C8231C);
  static const stampTint = Color(0x1FC8231C);

  /// Customer/product avatar colours: earthy and on-brand, none of them a
  /// status colour (so a random customer never looks "overdue"). No blue.
  static const avatars = [
    Color(0xFFC8231C), // stamp
    Color(0xFF9A5530), // clay
    Color(0xFF8A6A12), // ochre
    Color(0xFF55702A), // olive
    Color(0xFF7A3B5E), // plum
    Color(0xFF55585F), // ink grey
  ];
}
