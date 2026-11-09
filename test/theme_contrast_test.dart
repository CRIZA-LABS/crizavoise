import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crizavoise/theme/tokens.dart';

/// WCAG 2.x contrast ratio of [fg] drawn on [bg] (fg alpha-blended first).
double contrast(Color fg, Color bg) {
  double lum(Color c) {
    double ch(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
  }

  final blended = Color.alphaBlend(fg, bg);
  final a = lum(blended), b = lum(bg);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

void main() {
  for (final entry in {'light': CvColors.light, 'dark': CvColors.dark}.entries) {
    final name = entry.key;
    final p = entry.value;

    // [label, fg, bg, minimum] — 4.5 for text, 3.0 for UI parts/large text.
    final pairs = <(String, Color, Color, double)>[
      ('text / background', p.text, p.background, 4.5),
      ('text / surface1', p.text, p.surface1, 4.5),
      ('text / surface2', p.text, p.surface2, 4.5),
      ('text / surface3', p.text, p.surface3, 4.5),
      ('muted / background', p.textMuted, p.background, 4.5),
      ('muted / surface1', p.textMuted, p.surface1, 4.5),
      ('muted / surface3', p.textMuted, p.surface3, 4.5),
      ('primary / background', p.primary, p.background, 4.5),
      ('primary / surface2', p.primary, p.surface2, 4.5),
      ('onPrimary / primary', p.onPrimary, p.primary, 4.5),
      ('onAccent / accent', p.onAccent, p.accent, 4.5),
      ('accent / surface2', p.accent, p.surface2, 4.5),
      ('success / surface2', p.success, p.surface2, 4.5),
      ('warning / surface2', p.warning, p.surface2, 4.5),
      ('danger / surface2', p.danger, p.surface2, 4.5),
      ('info / surface2', p.info, p.surface2, 4.5),
      ('focus ring / background', p.focus, p.background, 3.0),
      ('strong border / surface2', p.borderStrong, p.surface2, 3.0),
    ];

    group('$name theme meets WCAG AA', () {
      final report = StringBuffer('\n$name theme contrast:\n');
      for (final (label, fg, bg, min) in pairs) {
        final ratio = contrast(fg, bg);
        report.writeln(
            '  ${label.padRight(26)} ${ratio.toStringAsFixed(2).padLeft(5)}:1  (min $min)');
        test(label, () => expect(ratio, greaterThanOrEqualTo(min)));
      }
      // ignore: avoid_print
      tearDownAll(() => print(report));
    });
  }
}
