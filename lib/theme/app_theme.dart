import 'package:flutter/material.dart';

import 'package:crizavoise/theme/tokens.dart';

/// Builds the CrizaVoise light and dark themes from lib/theme/tokens.dart.
class AppTheme {
  static ThemeData get light => _build(CvColors.light);
  static ThemeData get dark => _build(CvColors.dark);

  /// Inter and Bricolage ship as variable fonts; pass the weight as a font
  /// variation too so every platform renders the intended weight.
  static TextStyle _t(String family, double size, FontWeight w, Color c,
          {double? height, double? spacing}) =>
      TextStyle(
        fontFamily: family,
        fontFamilyFallback: CvType.fallback,
        fontSize: size,
        fontWeight: w,
        fontVariations: [FontVariation('wght', w.value.toDouble())],
        height: height,
        letterSpacing: spacing,
        color: c,
      );

  static TextTheme _textTheme(CvPalette p) {
    const h = CvType.heading, b = CvType.body;
    return TextTheme(
      displayLarge: _t(h, CvType.display, FontWeight.w700, p.text, height: 1.1, spacing: -0.8),
      displayMedium: _t(h, CvType.h1, FontWeight.w700, p.text, height: 1.1, spacing: -0.5),
      displaySmall: _t(h, CvType.h2, FontWeight.w700, p.text, height: 1.15),
      headlineLarge: _t(h, CvType.h1, FontWeight.w700, p.text, height: 1.15),
      headlineMedium: _t(h, CvType.h2, FontWeight.w700, p.text, height: 1.2),
      headlineSmall: _t(h, CvType.h3, FontWeight.w700, p.text, height: 1.25),
      titleLarge: _t(h, CvType.h4, FontWeight.w700, p.text, height: 1.3),
      titleMedium: _t(b, CvType.bodyLg, FontWeight.w600, p.text, height: 1.4),
      titleSmall: _t(b, CvType.bodyMd, FontWeight.w600, p.text, height: 1.4),
      bodyLarge: _t(b, CvType.bodyLg, FontWeight.w400, p.text, height: 1.55),
      bodyMedium: _t(b, CvType.bodyMd, FontWeight.w400, p.text, height: 1.5),
      bodySmall: _t(b, CvType.small, FontWeight.w400, p.textMuted, height: 1.45),
      labelLarge: _t(b, CvType.bodyMd, FontWeight.w600, p.text),
      labelMedium: _t(b, CvType.small, FontWeight.w600, p.text),
      labelSmall: _t(b, CvType.tiny, FontWeight.w600, p.textMuted, spacing: 0.4),
    );
  }

  static ThemeData _build(CvPalette p) {
    final isDark = p.brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: Color.alphaBlend(p.primary.withValues(alpha: 0.16), p.surface2),
      onPrimaryContainer: p.text,
      secondary: p.accent,
      onSecondary: p.onAccent,
      secondaryContainer: Color.alphaBlend(p.accent.withValues(alpha: 0.14), p.surface2),
      onSecondaryContainer: p.text,
      tertiary: p.info,
      onTertiary: p.onPrimary,
      error: p.danger,
      onError: isDark ? p.background : Colors.white,
      errorContainer: Color.alphaBlend(p.danger.withValues(alpha: 0.14), p.surface2),
      onErrorContainer: p.text,
      surface: p.surface1,
      onSurface: p.text,
      onSurfaceVariant: p.textMuted,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.surface1,
      surfaceContainer: p.surface1,
      surfaceContainerHigh: p.surface2,
      surfaceContainerHighest: isDark ? p.surface3 : p.surface2,
      outline: p.borderStrong,
      outlineVariant: p.border,
      inverseSurface: p.text,
      onInverseSurface: p.background,
      inversePrimary: isDark ? CvColors.light.primary : CvColors.dark.primary,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );
    final text = _textTheme(p);
    final shapeMd = RoundedRectangleBorder(borderRadius: BorderRadius.circular(CvRadius.md));
    const minTap = Size(64, CvSpace.tap);
    final focusRing = WidgetStateProperty.resolveWith<BorderSide?>((s) =>
        s.contains(WidgetState.focused) ? BorderSide(color: p.focus, width: 2) : null);

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      primaryColor: p.primary,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      cardColor: p.surface1,
      dividerColor: p.border,
      fontFamily: CvType.body,
      fontFamilyFallback: CvType.fallback,
      textTheme: text,
      // Platform density: compact with a mouse (dense desktop tables keep
      // fitting), roomy on touch. Primary buttons keep a 48px minimum via
      // their own themes below.
      visualDensity: VisualDensity.adaptivePlatformDensity,
      focusColor: p.focus.withValues(alpha: 0.18),
      extensions: [CrizaTokens(palette: p)],
      appBarTheme: AppBarTheme(
        // Ink bar in light mode (the icon's tile), raised surface in dark.
        backgroundColor: isDark ? p.surface2 : CvBrand.ink,
        foregroundColor: isDark ? p.text : CvBrand.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: isDark ? p.text : CvBrand.paper),
      ),
      cardTheme: CardThemeData(
        color: p.surface1,
        surfaceTintColor: Colors.transparent,
        // Flat cards everywhere: no shadow even when a screen sets elevation.
        shadowColor: Colors.transparent,
        elevation: CvElevation.card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CvRadius.md),
          side: BorderSide(color: p.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CvRadius.lg)),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(minTap),
          shape: WidgetStatePropertyAll(shapeMd),
          side: focusRing,
          textStyle: WidgetStatePropertyAll(text.labelLarge),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(minTap),
          shape: WidgetStatePropertyAll(shapeMd),
          side: focusRing,
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(p.primary),
          foregroundColor: WidgetStatePropertyAll(p.onPrimary),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(minTap),
          shape: WidgetStatePropertyAll(shapeMd),
          side: WidgetStateProperty.resolveWith((s) => BorderSide(
              color: s.contains(WidgetState.focused) ? p.focus : p.borderStrong,
              width: s.contains(WidgetState.focused) ? 2 : 1)),
          foregroundColor: WidgetStatePropertyAll(p.text),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 40)),
          shape: WidgetStatePropertyAll(shapeMd),
          side: focusRing,
          foregroundColor: WidgetStatePropertyAll(p.primary),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface2,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: CvSpace.md, vertical: 14),
        labelStyle: TextStyle(color: p.textMuted),
        hintStyle: TextStyle(color: p.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CvRadius.sm),
          borderSide: BorderSide(color: p.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CvRadius.sm),
          borderSide: BorderSide(color: p.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CvRadius.sm),
          borderSide: BorderSide(color: p.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CvRadius.sm),
          borderSide: BorderSide(color: p.danger),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.text,
        contentTextStyle: text.bodyMedium?.copyWith(color: p.background),
        showCloseIcon: true,
        closeIconColor: p.background,
        shape: shapeMd,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface2,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CvRadius.pill)),
        labelStyle: text.labelMedium,
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 10,
        iconColor: p.textMuted,
        shape: shapeMd,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.surface1,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: p.primary),
        unselectedIconTheme: IconThemeData(color: p.textMuted),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.text,
          borderRadius: BorderRadius.circular(CvRadius.sm),
        ),
        textStyle: text.bodySmall?.copyWith(color: p.background),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
      // Toggles: clearly ON (solid Stamp track, contrasting thumb + check
      // icon) vs OFF (muted track with an outline) in both themes. Screens
      // must not override these colours.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return p.borderStrong;
          return s.contains(WidgetState.selected) ? p.onPrimary : p.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return p.surface3;
          return s.contains(WidgetState.selected) ? p.primary : p.surface3;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? p.primary : p.borderStrong),
        thumbIcon: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? Icon(Icons.check, size: 14, color: p.primary)
            : null),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? p.primary : Colors.transparent),
        checkColor: WidgetStatePropertyAll(p.onPrimary),
        side: BorderSide(color: p.borderStrong, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? p.primary : p.borderStrong),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.windows: CvPageTransitionsBuilder(),
        TargetPlatform.linux: CvPageTransitionsBuilder(),
        TargetPlatform.macOS: CvPageTransitionsBuilder(),
        TargetPlatform.android: CvPageTransitionsBuilder(),
        TargetPlatform.iOS: CvPageTransitionsBuilder(),
      }),
    );
  }
}


/// Page transition: a short fade-forward; with reduced motion, a plain fade
/// only (no movement), per the motion rules in docs/brand.md.
class CvPageTransitionsBuilder extends PageTransitionsBuilder {
  const CvPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context,
      Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (MediaQuery.maybeDisableAnimationsOf(context) == true) {
      return FadeTransition(opacity: animation, child: child);
    }
    return const FadeForwardsPageTransitionsBuilder()
        .buildTransitions(route, context, animation, secondaryAnimation, child);
  }
}
