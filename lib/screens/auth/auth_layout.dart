import 'package:flutter/material.dart';

import 'package:crizavoise/common/app_config.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/theme/brand_assets.dart';
import 'package:crizavoise/theme/tokens.dart';

/// One look for every sign-in screen (create account, recovery code, forgot
/// password): brand lockup, a centred card, a title and a short line of help.
class AuthLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool canPop;
  final double maxWidth;

  const AuthLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.canPop = true,
    this.maxWidth = 460,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isPhone = width < 600;
    return PopScope(
      canPop: canPop,
      child: Scaffold(
        appBar: canPop && Navigator.of(context).canPop()
            ? AppBar(
                backgroundColor: Colors.transparent,
                foregroundColor: scheme.onSurface,
                elevation: 0,
              )
            : null,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: CvSpace.md, vertical: CvSpace.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      BrandAssets.lockupFor(theme.brightness),
                      height: 44,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      semanticLabel: AppConfig.name,
                    ),
                    const SizedBox(height: CvSpace.lg),
                    Card(
                      color: scheme.surfaceContainer,
                      child: Padding(
                        padding: EdgeInsets.all(isPhone ? CvSpace.md + 4 : CvSpace.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(title, style: theme.textTheme.headlineSmall),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: CvSpace.sm),
                              Text(subtitle!,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: scheme.onSurfaceVariant)),
                            ],
                            const SizedBox(height: CvSpace.lg),
                            ...children,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline error or success message inside an auth card.
class AuthMessage extends StatelessWidget {
  final String text;
  final bool isError;
  const AuthMessage(this.text, {super.key, this.isError = true});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isError ? scheme.error : CrizaTokens.of(context).success;
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: CvSpace.md),
        padding: const EdgeInsets.all(CvSpace.sm + 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(CvRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                size: 20, color: color),
            const SizedBox(width: CvSpace.sm),
            Expanded(child: Text(text, style: TextStyle(color: scheme.onSurface))),
          ],
        ),
      ),
    );
  }
}

/// Password field with a show/hide toggle.
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? helperText;
  final List<String> autofillHints;

  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.helperText,
    this.autofillHints = const [AutofillHints.password],
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      autofillHints: widget.autofillHints,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        helperMaxLines: 2,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _obscure ? l10n.authShowPassword : l10n.authHidePassword,
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

/// Shared password rules for creating and resetting passwords.
String? passwordIssue(AppLocalizations l10n,
    {required String password, required String confirm, required String username}) {
  if (password.length < 8) return l10n.authPasswordTooShort;
  if (password.toLowerCase() == username.trim().toLowerCase()) return l10n.authPasswordIsUsername;
  if (password != confirm) return l10n.authPasswordsDontMatch;
  return null;
}
