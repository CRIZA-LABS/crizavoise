import 'package:flutter/material.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/theme/tokens.dart';

/// Dismissible "New: ..." feature-discovery banner — ONE consistent CrizaVoise
/// style for every banner (layout, theme, shortcuts, support, purchases):
/// card surface, Stamp-tinted icon badge, ink title, muted subtitle, Stamp
/// action. The colour parameters are kept for source compatibility but are
/// intentionally ignored so banners can't drift into a rainbow again.
class DiscoveryBanner extends StatelessWidget {
  final bool visible;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final Widget title;
  final Widget subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final Color actionColor;
  final Color? actionBackgroundColor;
  final VoidCallback onDismiss;
  final Color dismissIconColor;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry margin;
  final double iconSize;

  const DiscoveryBanner({
    super.key,
    required this.visible,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    required this.actionColor,
    this.actionBackgroundColor,
    required this.onDismiss,
    required this.dismissIconColor,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.margin = const EdgeInsets.only(bottom: 20),
    this.iconSize = 20,
  });

  /// Re-style plain Text so every banner reads the same; other widgets
  /// (e.g. a title with a BETA chip) are kept as they are.
  Widget _restyle(Widget w, TextStyle? style) =>
      w is Text && w.data != null ? Text(w.data!, style: style) : w;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    return AnimatedSize(
      duration: CvMotion.base,
      curve: CvMotion.standard,
      child: visible
          ? Container(
              margin: margin,
              padding: const EdgeInsets.fromLTRB(CvSpace.md, CvSpace.sm + 4, CvSpace.xs, CvSpace.sm + 4),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(CvRadius.md),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: crossAxisAlignment,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: scheme.primary, size: 20),
                  ),
                  const SizedBox(width: CvSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _restyle(title, text.titleSmall?.copyWith(color: scheme.onSurface)),
                        const SizedBox(height: 2),
                        _restyle(subtitle, text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: CvSpace.sm),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: CvSpace.md),
                    ),
                    child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: scheme.onSurfaceVariant,
                    onPressed: onDismiss,
                    tooltip: AppLocalizations.of(context)!.actionDismiss,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
