// CrizaVoise design tokens — the single source of truth for colour, type,
// spacing, radius, elevation, motion and z-order. Values come from the Criza
// Labs site (D:\AIProject\CRIZA\src\styles\tokens.css); see docs/brand.md.
// Widgets read them through Theme.of(context) (ColorScheme + component themes)
// or the CrizaTokens ThemeExtension — never hard-code colours in widgets.
import 'package:flutter/material.dart';

/// Raw brand colours — "Ink · Paper · Stamp", the colours of a bill book.
/// They match the app icon exactly (tool/brand/mark.js). No blue: Stamp red
/// is the Criza Labs red (the "A" and the full stop in "CRIZA."), Ink and
/// Paper come from the Criza site's dark and paper sections.
class CvBrand {
  static const ink = Color(0xFF121316);
  static const inkLift = Color(0xFF24262B);
  static const paper = Color(0xFFF6F1E7);
  static const stamp = Color(0xFFD7261E); // icon slot + the total's dot
  static const stampBright = Color(0xFFEE3A2C); // on dark surfaces

  /// Used sparingly for brand moments (hero headers, empty states).
  static const stampGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEE3A2C), Color(0xFFB71F18)],
  );
}

/// One theme's semantic palette.
@immutable
class CvPalette {
  final Brightness brightness;
  final Color background;
  final Color surface1; // cards, panels
  final Color surface2; // raised: dialogs, menus, inputs
  final Color surface3; // pressed / selected / chrome
  final Color text;
  final Color textMuted;
  final Color border;
  final Color borderStrong;
  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color focus;

  const CvPalette({
    required this.brightness,
    required this.background,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.borderStrong,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.focus,
  });
}

class CvColors {
  /// Light theme: Paper with Ink, Stamp red for brand accents.
  static const light = CvPalette(
    brightness: Brightness.light,
    background: Color(0xFFF6F1E7), // Paper
    surface1: Color(0xFFFBF8F2),
    surface2: Color(0xFFFFFFFF),
    surface3: Color(0xFFEEE7DA),
    text: Color(0xFF121316), // Ink
    textMuted: Color(0xFF55585F),
    border: Color(0x29121316), // ink @ 16%
    borderStrong: Color(0x80121316), // ink @ 50%
    primary: Color(0xFFC8231C), // Stamp red: actions, selection, key icons
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF121316), // Ink: structure (app bars, the icon tile)
    onAccent: Color(0xFFF6F1E7),
    success: Color(0xFF1C7346),
    warning: Color(0xFF8A5300),
    danger: Color(0xFF9B1C16), // deeper than Stamp red; always shown with an icon
    info: Color(0xFF3A3D45),
    focus: Color(0xFFC8231C),
  );

  /// Dark theme: Ink with Paper, Stamp red lifted for dark surfaces.
  static const dark = CvPalette(
    brightness: Brightness.dark,
    background: Color(0xFF0E0F12),
    surface1: Color(0xFF16171B), // = icon tile family
    surface2: Color(0xFF1C1E23),
    surface3: Color(0xFF26282E),
    text: Color(0xFFF3EEE4), // Paper
    textMuted: Color(0xFFB7B2A8),
    border: Color(0x1FFFFFFF), // white @ 12%
    borderStrong: Color(0x66FFFFFF), // white @ 40%
    primary: Color(0xFFFF5A4C), // Stamp red, lifted for dark surfaces
    onPrimary: Color(0xFF121316),
    accent: Color(0xFFF3EEE4), // Paper
    onAccent: Color(0xFF121316),
    success: Color(0xFF4FD08C),
    warning: Color(0xFFFFC857),
    danger: Color(0xFFFF8A80),
    info: Color(0xFFD0CBC1),
    focus: Color(0xFFFF5A4C),
  );

  static CvPalette of(Brightness b) => b == Brightness.dark ? dark : light;
}

/// Type families and scale (logical px).
class CvType {
  static const heading = 'BricolageGrotesque';
  static const body = 'Inter';

  /// Non-Latin app text (Devanagari, Tibetan) falls back to bundled Noto.
  static const fallback = ['NotoSansDevanagari', 'NotoSansGujarati', 'NotoSerifTibetan'];

  static const display = 40.0;
  static const h1 = 32.0;
  static const h2 = 26.0;
  static const h3 = 21.0;
  static const h4 = 18.0;
  static const bodyLg = 16.0;
  static const bodyMd = 14.0;
  static const small = 12.5;
  static const tiny = 11.0;
}

/// 4-pt spacing scale.
class CvSpace {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  /// Minimum touch/click target.
  static const tap = 48.0;
}

class CvRadius {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const pill = 999.0;
}

class CvElevation {
  static const none = 0.0;
  static const card = 0.0; // cards use a hairline border, not a shadow
  static const raised = 2.0;
  static const overlay = 8.0;

  static List<BoxShadow> pop(Brightness b) => [
        BoxShadow(
          color: b == Brightness.dark
              ? const Color(0x8C000000)
              : const Color(0x2912131A),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];
}

/// Motion durations and curves. Animate transform/opacity only; when
/// [reduced] is true (MediaQuery.disableAnimations or the in-app setting),
/// use fades of [fast].
class CvMotion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 320);

  static const standard = Cubic(0.2, 0, 0, 1);
  static const emphasized = Cubic(0.3, 0, 0, 1.2);
  static const exit = Cubic(0.3, 0, 1, 1);

  static Duration scaled(BuildContext context, Duration d) =>
      MediaQuery.maybeDisableAnimationsOf(context) == true ? Duration.zero : d;
}

/// Z-order for overlays built with Stack/Overlay.
class CvZ {
  static const base = 0;
  static const sticky = 10;
  static const dropdown = 20;
  static const dialog = 30;
  static const toast = 40;
}

/// Theme extension carrying what ColorScheme can't: brand gradients, extra
/// semantic colours and the surface ladder.
@immutable
class CrizaTokens extends ThemeExtension<CrizaTokens> {
  final CvPalette palette;
  final Gradient brandGradient;

  const CrizaTokens({
    required this.palette,
    this.brandGradient = CvBrand.stampGradient,
  });

  Color get success => palette.success;
  Color get warning => palette.warning;
  Color get info => palette.info;
  Color get textMuted => palette.textMuted;
  Color get surface1 => palette.surface1;
  Color get surface2 => palette.surface2;
  Color get surface3 => palette.surface3;

  static CrizaTokens of(BuildContext context) =>
      Theme.of(context).extension<CrizaTokens>() ??
      CrizaTokens(palette: CvColors.of(Theme.of(context).brightness));

  @override
  CrizaTokens copyWith({CvPalette? palette}) =>
      CrizaTokens(palette: palette ?? this.palette);

  @override
  CrizaTokens lerp(ThemeExtension<CrizaTokens>? other, double t) =>
      t < 0.5 ? this : (other as CrizaTokens? ?? this);
}
