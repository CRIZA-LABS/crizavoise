// CrizaVoise design tokens — the single source of truth for colour, type,
// spacing, radius, elevation, motion and z-order. Values come from the Criza
// Labs site (D:\AIProject\CRIZA\src\styles\tokens.css); see docs/brand.md.
// Widgets read them through Theme.of(context) (ColorScheme + component themes)
// or the CrizaTokens ThemeExtension — never hard-code colours in widgets.
import 'package:flutter/material.dart';

/// Raw brand hues. Use for the logo and accents, not body text.
/// The logo ("Ribbon V") uses Criza Labs' red and blue ribbons on the Criza
/// navy plate; magenta appears only at the fold seam.
class CvBrand {
  static const red = Color(0xFFFD352A);
  static const pink = Color(0xFFF51E91);
  static const blue = Color(0xFF019FFB);

  static const ribbonRed = Color(0xFFE2231A);
  static const ribbonRedLight = Color(0xFFFF5A3C);
  static const ribbonBlue = Color(0xFF0A8EF0);
  static const ribbonBlueLight = Color(0xFF3CC8FF);
  static const navy = Color(0xFF071426);
  static const navyTop = Color(0xFF122A4C);

  /// The two-ribbon pairing (red → blue) for accent strokes and highlights.
  static const ribbonGradient = LinearGradient(
    colors: [ribbonRedLight, ribbonRed, ribbonBlue, ribbonBlueLight],
    stops: [0, 0.42, 0.58, 1],
  );

  /// Logo plate.
  static const plateGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navyTop, navy],
  );

  /// Logo/accent gradient: red → pink (45%) → blue.
  static const gradient = LinearGradient(
    colors: [red, pink, blue],
    stops: [0, 0.45, 1],
  );

  /// Darkened gradient for filled call-to-action surfaces; white text passes
  /// AA across the whole area.
  static const ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFD81F30), Color(0xFFC0157A), Color(0xFF0A6FC2)],
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
  /// Light theme: the Criza "paper" palette.
  static const light = CvPalette(
    brightness: Brightness.light,
    background: Color(0xFFF4EFE6),
    surface1: Color(0xFFFBF8F3),
    surface2: Color(0xFFFFFFFF),
    surface3: Color(0xFFEBE4D7),
    text: Color(0xFF12131A),
    textMuted: Color(0xFF4A4E59),
    border: Color(0x2912131A), // ink @ 16%
    borderStrong: Color(0x8012131A), // ink @ 50% (site uses 42%; raised for 3:1 UI contrast)
    primary: Color(0xFF0A5EA8),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFFC81E33),
    onAccent: Color(0xFFFFFFFF),
    success: Color(0xFF17703F),
    warning: Color(0xFF8A5300),
    danger: Color(0xFFB3261E),
    info: Color(0xFF0A5EA8),
    focus: Color(0xFFC0157A),
  );

  /// Dark theme: the Criza site's native palette.
  static const dark = CvPalette(
    brightness: Brightness.dark,
    background: Color(0xFF08090D),
    surface1: Color(0xFF0E1016),
    surface2: Color(0xFF13151D),
    surface3: Color(0xFF1C1F2A),
    text: Color(0xFFF6F2EA),
    textMuted: Color(0xFFB3B7C2),
    border: Color(0x1FFFFFFF), // white @ 12%
    borderStrong: Color(0x66FFFFFF), // white @ 40% (site uses 30%; raised for 3:1 UI contrast)
    primary: Color(0xFF5CC0FF),
    onPrimary: Color(0xFF08090D),
    accent: Color(0xFFFF6B78),
    onAccent: Color(0xFF08090D),
    success: Color(0xFF3DDC97),
    warning: Color(0xFFFFC857),
    danger: Color(0xFFFF8A80),
    info: Color(0xFF5CC0FF),
    focus: Color(0xFFF51E91),
  );

  static CvPalette of(Brightness b) => b == Brightness.dark ? dark : light;
}

/// Type families and scale (logical px).
class CvType {
  static const heading = 'BricolageGrotesque';
  static const body = 'Inter';

  /// Non-Latin app text (Devanagari, Tibetan) falls back to bundled Noto.
  static const fallback = ['NotoSansDevanagari', 'NotoSerifTibetan'];

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
  final Gradient ctaGradient;

  const CrizaTokens({
    required this.palette,
    this.brandGradient = CvBrand.gradient,
    this.ctaGradient = CvBrand.ctaGradient,
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
