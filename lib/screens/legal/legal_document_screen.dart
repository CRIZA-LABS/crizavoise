import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:crizavoise/theme/tokens.dart';

/// Shows a bundled Markdown document (Terms of Use, Privacy Policy) as
/// readable text: headings, paragraphs, bullet lists and **bold** runs.
/// A tiny renderer is enough for these documents and avoids a dependency.
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String asset;
  const LegalDocumentScreen({super.key, required this.title, required this.asset});

  static Future<void> open(BuildContext context, {required String title, required String asset}) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LegalDocumentScreen(title: title, asset: asset)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(asset),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SelectionArea(
                child: ListView(
                  padding: const EdgeInsets.all(CvSpace.lg),
                  children: MarkdownLite.render(context, snap.data!),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Minimal Markdown → widgets for our legal documents.
class MarkdownLite {
  static List<Widget> render(BuildContext context, String md) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final out = <Widget>[];
    final para = StringBuffer();

    void flush() {
      if (para.isEmpty) return;
      out.add(Padding(
        padding: const EdgeInsets.only(bottom: CvSpace.sm + 4),
        child: Text.rich(_inline(para.toString().trim(), t.bodyMedium), style: t.bodyMedium),
      ));
      para.clear();
    }

    for (final raw in md.split('\n')) {
      final line = raw.trimRight();
      if (line.isEmpty) {
        flush();
      } else if (line.startsWith('# ')) {
        flush();
        out.add(Padding(
          padding: const EdgeInsets.only(bottom: CvSpace.sm),
          child: Text(line.substring(2), style: t.headlineSmall),
        ));
      } else if (line.startsWith('## ')) {
        flush();
        out.add(Padding(
          padding: const EdgeInsets.only(top: CvSpace.md, bottom: CvSpace.sm),
          child: Text(line.substring(3), style: t.titleLarge),
        ));
      } else if (line.startsWith('- ')) {
        flush();
        out.add(Padding(
          padding: const EdgeInsets.only(left: CvSpace.sm, bottom: CvSpace.xs + 2),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 7, right: CvSpace.sm),
              child: Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle)),
            ),
            Expanded(child: Text.rich(_inline(line.substring(2), t.bodyMedium), style: t.bodyMedium)),
          ]),
        ));
      } else {
        if (para.isNotEmpty) para.write(' ');
        para.write(line);
      }
    }
    flush();
    return out;
  }

  /// **bold** runs; everything else plain.
  static TextSpan _inline(String text, TextStyle? base) {
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      spans.add(TextSpan(
          text: parts[i],
          style: i.isOdd ? const TextStyle(fontWeight: FontWeight.w700) : null));
    }
    return TextSpan(children: spans);
  }
}
