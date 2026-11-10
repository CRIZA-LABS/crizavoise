import 'package:flutter/widgets.dart';

/// Paths of the CrizaVoise brand assets (see docs/brand.md).
///
/// Mark: "the bill being printed" — a shop bill coming out of a printer slot,
/// its total ending in the Criza red dot. It comes in a dark (navy tile) and
/// a light (white tile) version; use [markFor] to follow the active theme.
/// Lockup: "CRIZA VOISE.", built from the Criza master lettering exactly like
/// "CRIZA LABS." (raster, as the parent's is).
class BrandAssets {
  static const markDark = 'assets/brand/mark-dark.svg';
  static const markLight = 'assets/brand/mark-light.svg';
  static const markDarkSmall = 'assets/brand/mark-dark-small.svg';
  static const markLightSmall = 'assets/brand/mark-light-small.svg';
  static const symbolOnDark = 'assets/brand/symbol-on-dark.svg';
  static const symbolOnLight = 'assets/brand/symbol-on-light.svg';
  static const symbolMono = 'assets/brand/symbol-mono.svg';

  /// "CRIZA VOISE." lockup (PNG, 216px tall). Minimum display height 36px.
  static const lockupLight = 'assets/brand/lockup-light.png';
  static const lockupDark = 'assets/brand/lockup-dark.png';

  /// The app mark for the current theme. Under 48 logical px the simplified
  /// small mark is used.
  static String markFor(Brightness b, {double size = 64}) {
    final dark = b == Brightness.dark;
    if (size < 48) return dark ? markDarkSmall : markLightSmall;
    return dark ? markDark : markLight;
  }

  static String lockupFor(Brightness b) =>
      b == Brightness.dark ? lockupDark : lockupLight;
}
