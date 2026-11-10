import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:crizavoise/database/product_service.dart';
import 'package:crizavoise/l10n/app_localizations.dart';

/// "Quick code" input for a product: a short code typed at the counter to
/// find the item fast ("R5", "101"). Shows the format rule live and offers a
/// suggestion from the product name. Uniqueness is checked on save with
/// [QuickCodeField.uniqueError].
class QuickCodeField extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController nameController;
  final String? excludeProductId;
  final bool readOnly;
  final String? errorText;

  const QuickCodeField({
    super.key,
    required this.controller,
    required this.nameController,
    this.excludeProductId,
    this.readOnly = false,
    this.errorText,
  });

  /// Localised error if [code] is already used by another product, else null.
  static Future<String?> uniqueError(BuildContext context, String code,
      {String? excludeProductId}) async {
    final l10n = AppLocalizations.of(context)!;
    if (await ProductQuickCode.isTaken(code, excludeProductId: excludeProductId)) {
      return l10n.productQuickCodeTaken;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLength: ProductQuickCode.maxLength,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
        TextInputFormatter.withFunction(
            (o, n) => n.copyWith(text: n.text.toUpperCase())),
      ],
      decoration: InputDecoration(
        labelText: l10n.productQuickCodeLabel,
        helperText: readOnly ? null : l10n.productQuickCodeHelper,
        helperMaxLines: 2,
        errorText: errorText,
        prefixIcon: const Icon(Icons.bolt_outlined),
        suffixIcon: readOnly
            ? null
            : IconButton(
                tooltip: l10n.productQuickCodeSuggest,
                icon: const Icon(Icons.auto_fix_high_outlined),
                onPressed: () async {
                  final code = await ProductQuickCode.suggest(nameController.text,
                      excludeProductId: excludeProductId);
                  controller.text = code;
                },
              ),
      ),
      validator: (v) => ProductQuickCode.formatIssue(v ?? '') == null
          ? null
          : l10n.productQuickCodeInvalid,
    );
  }
}

/// Small monospace chip showing a product's quick code next to its name.
class QuickCodeBadge extends StatelessWidget {
  final String code;
  const QuickCodeBadge(this.code, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.06),
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: 'monospace',
          fontFamilyFallback: const ['Consolas', 'Menlo'],
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
