import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:crizavoise/database/product_photo_service.dart';
import 'package:crizavoise/l10n/app_localizations.dart';
import 'package:crizavoise/services/image_import_service.dart';
import 'package:crizavoise/theme/tokens.dart';

/// Square product thumbnail; shows [fallback] (or a box icon) without a photo.
class ProductThumb extends StatelessWidget {
  final String productId;
  final double size;
  final Widget? fallback;

  /// Space after the photo (only when there is one), for inline use.
  final double trailingGap;

  const ProductThumb(
      {super.key, required this.productId, this.size = 40, this.fallback, this.trailingGap = 0});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<Uint8List?>(
      key: ValueKey('$productId-${ProductPhotoService.version}'),
      future: ProductPhotoService.get(productId),
      builder: (context, snap) {
        final bytes = snap.data;
        if (bytes == null) {
          return fallback ??
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(CvRadius.sm),
                ),
                child: Icon(Icons.inventory_2_outlined, size: size * 0.5, color: scheme.onSurfaceVariant),
              );
        }
        final photo = ClipRRect(
          borderRadius: BorderRadius.circular(CvRadius.sm),
          child: Image.memory(bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
              gaplessPlayback: true),
        );
        return trailingGap == 0
            ? photo
            : Padding(padding: EdgeInsets.only(right: trailingGap), child: photo);
      },
    );
  }
}

/// Add / change / remove a product photo.
///
/// For an existing product ([productId] set) changes are saved at once.
/// For a product not saved yet, the photo is held and handed to
/// [onPendingChanged]; the caller saves it after creating the product.
class ProductPhotoEditor extends StatefulWidget {
  final String? productId;
  final bool readOnly;
  final ValueChanged<Uint8List?>? onPendingChanged;

  const ProductPhotoEditor({super.key, this.productId, this.readOnly = false, this.onPendingChanged});

  @override
  State<ProductPhotoEditor> createState() => _ProductPhotoEditorState();
}

class _ProductPhotoEditorState extends State<ProductPhotoEditor> {
  Uint8List? _bytes;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final id = widget.productId;
    if (id == null) {
      _loaded = true;
    } else {
      ProductPhotoService.get(id).then((b) {
        if (mounted) {
          setState(() {
          _bytes = b;
          _loaded = true;
        });
        }
      });
    }
  }

  Future<void> _pick() async {
    final r = await ImageImportService.pickAndPrepare(context, ImageKind.productPhoto);
    if (r == null) return;
    final id = widget.productId;
    if (id != null) {
      await ProductPhotoService.set(id, r.bytes);
    } else {
      widget.onPendingChanged?.call(r.bytes);
    }
    if (mounted) setState(() => _bytes = r.bytes);
  }

  Future<void> _remove() async {
    final id = widget.productId;
    if (id != null) {
      await ProductPhotoService.remove(id);
    } else {
      widget.onPendingChanged?.call(null);
    }
    if (mounted) setState(() => _bytes = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    if (!_loaded) return const SizedBox(height: 88);
    if (widget.readOnly && _bytes == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: CvSpace.md),
      child: Row(
        children: [
          Semantics(
            image: true,
            label: l10n.productPhotoLabel,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(CvRadius.md),
                border: Border.all(color: scheme.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: _bytes == null
                  ? Icon(Icons.add_a_photo_outlined, color: scheme.onSurfaceVariant)
                  : Image.memory(_bytes!, fit: BoxFit.cover),
            ),
          ),
          if (!widget.readOnly) ...[
            const SizedBox(width: CvSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: CvSpace.sm,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.photo_outlined, size: 18),
                        label: Text(_bytes == null ? l10n.productPhotoAdd : l10n.productPhotoChange),
                        onPressed: _pick,
                      ),
                      if (_bytes != null)
                        TextButton(
                          onPressed: _remove,
                          style: TextButton.styleFrom(foregroundColor: scheme.error),
                          child: Text(l10n.productPhotoRemove),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.productPhotoHint,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
