import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'package:crizavoise/l10n/app_localizations.dart';

/// What the picked image is for. Each kind has the size it is stored at and
/// the minimum size we recommend so it prints sharp.
///
/// PDFs draw the logo at most 120pt wide, the signature at most 70pt tall and
/// the watermark as a full-width strip; at 300 dpi print quality that needs
/// roughly 500 / 300 / 1200 px, so the stored sizes below keep a margin.
enum ImageKind {
  logo(maxSide: 1024, recommendedMin: 600),
  signature(maxSide: 1000, recommendedMin: 400),
  watermark(maxSide: 1600, recommendedMin: 1200),
  productPhoto(maxSide: 400, recommendedMin: 300, jpegQuality: 80);

  const ImageKind({required this.maxSide, required this.recommendedMin, this.jpegQuality});

  /// When set, photos without transparency are always stored as JPEG at this
  /// quality (small files; product photos are not printed large).
  final int? jpegQuality;

  /// Longest side, in pixels, the stored image is resized down to.
  final int maxSide;

  /// Below this (longest side) the image may look soft when printed.
  final int recommendedMin;
}

/// Result of [ImageImportService.prepare].
class ImageImportResult {
  final Uint8List bytes;
  final int originalWidth;
  final int originalHeight;
  final int width;
  final int height;
  final bool hasTransparency;

  const ImageImportResult({
    required this.bytes,
    required this.originalWidth,
    required this.originalHeight,
    required this.width,
    required this.height,
    required this.hasTransparency,
  });

  String get base64 => base64Encode(bytes);
  bool get wasResized => width != originalWidth || height != originalHeight;
  int get longestSide => math.max(width, height);
}

/// Why an image could not be used.
enum ImageImportError { unreadable, fileTooLarge }

class ImageImportException implements Exception {
  final ImageImportError error;
  const ImageImportException(this.error);
}

/// Turns any reasonable picked image into one that fits CrizaVoise:
/// fixes phone-camera rotation, resizes it down (never up) to the kind's
/// size, keeps transparency (PNG) and stores photos without transparency
/// compactly (JPEG). Replaces the old "must be under 1080×1080 / 2 MB" rule.
class ImageImportService {
  /// Accepted file types in the picker.
  static const extensions = ['png', 'jpg', 'jpeg', 'webp', 'bmp', 'gif'];

  /// Safety cap only (very large files could exhaust memory while decoding).
  static const maxFileBytes = 40 * 1024 * 1024;

  /// Above this, a PNG without transparency is re-encoded as JPEG.
  static const _pngBudgetBytes = 600 * 1024;

  /// Processes [bytes] for [kind] on a background isolate.
  static Future<ImageImportResult> prepare(Uint8List bytes, ImageKind kind) async {
    if (bytes.length > maxFileBytes) {
      throw const ImageImportException(ImageImportError.fileTooLarge);
    }
    final maxSide = kind.maxSide, q = kind.jpegQuality;
    final result = await Isolate.run(() => _process(bytes, maxSide, jpegQuality: q));
    if (result == null) throw const ImageImportException(ImageImportError.unreadable);
    return result;
  }

  /// Synchronous core, exposed for tests.
  static ImageImportResult? processSync(Uint8List bytes, ImageKind kind) =>
      _process(bytes, kind.maxSide, jpegQuality: kind.jpegQuality);

  static ImageImportResult? _process(Uint8List bytes, int maxSide, {int? jpegQuality}) {
    img.Image? decoded;
    try {
      decoded = img.decodeImage(bytes);
    } catch (_) {
      decoded = null;
    }
    if (decoded == null) return null;

    final originalW = decoded.width, originalH = decoded.height;
    // Phone photos store rotation in EXIF; apply it so the logo isn't sideways.
    var image = img.bakeOrientation(decoded);

    final longest = math.max(image.width, image.height);
    if (longest > maxSide) {
      final scale = maxSide / longest;
      image = img.copyResize(
        image,
        width: math.max(1, (image.width * scale).round()),
        height: math.max(1, (image.height * scale).round()),
        interpolation: img.Interpolation.average, // best for downscaling
      );
    }

    final transparent = _hasTransparency(image);
    Uint8List out = img.encodePng(image, level: 6);
    if (!transparent && jpegQuality != null) {
      out = img.encodeJpg(image, quality: jpegQuality);
    } else if (!transparent && out.length > _pngBudgetBytes) {
      out = img.encodeJpg(image, quality: 90);
    }
    return ImageImportResult(
      bytes: out,
      originalWidth: originalW,
      originalHeight: originalH,
      width: image.width,
      height: image.height,
      hasTransparency: transparent,
    );
  }

  static bool _hasTransparency(img.Image image) {
    if (!image.hasAlpha) return false;
    // Sample a grid; logos with transparency have it at the edges anyway.
    final stepX = math.max(1, image.width ~/ 64), stepY = math.max(1, image.height ~/ 64);
    for (var y = 0; y < image.height; y += stepY) {
      for (var x = 0; x < image.width; x += stepX) {
        if (image.getPixel(x, y).a < image.maxChannelValue) return true;
      }
    }
    return false;
  }

  /// Recommended-size text for [kind], shown under each upload button.
  static String recommendation(AppLocalizations l10n, ImageKind kind) => switch (kind) {
        ImageKind.logo => l10n.imageImportLogoHint,
        ImageKind.signature => l10n.imageImportSignatureHint,
        ImageKind.watermark => l10n.imageImportWatermarkHint,
        ImageKind.productPhoto => l10n.productPhotoHint,
      };

  /// Opens the file picker, prepares the image and tells the user what
  /// happened. Returns null if the user cancelled or the image was unusable.
  static Future<ImageImportResult?> pickAndPrepare(
      BuildContext context, ImageKind kind) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    final path = picked?.files.single.path;
    if (path == null || !context.mounted) return null;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final error = Theme.of(context).colorScheme.error;
    try {
      final bytes = await File(path).readAsBytes();
      final r = await prepare(bytes, kind);
      final String message;
      if (r.longestSide < kind.recommendedMin) {
        message = l10n.imageImportTooSmallMessage(
            '${r.width}×${r.height}', '${kind.recommendedMin}');
      } else if (r.wasResized) {
        message = l10n.imageImportResizedMessage(
            '${r.originalWidth}×${r.originalHeight}', '${r.width}×${r.height}');
      } else {
        message = l10n.imageImportAddedMessage;
      }
      messenger.showSnackBar(SnackBar(
        content: Row(children: [
          Icon(r.longestSide < kind.recommendedMin
              ? Icons.info_outline_rounded
              : Icons.check_circle_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ]),
        duration: const Duration(seconds: 5),
      ));
      return r;
    } on ImageImportException catch (e) {
      messenger.showSnackBar(SnackBar(
        backgroundColor: error,
        content: Text(e.error == ImageImportError.fileTooLarge
            ? l10n.imageImportFileTooLargeMessage('${maxFileBytes ~/ (1024 * 1024)}')
            : l10n.imageImportUnreadableMessage),
      ));
      return null;
    } on FileSystemException {
      messenger.showSnackBar(SnackBar(
          backgroundColor: error, content: Text(l10n.imageImportUnreadableMessage)));
      return null;
    }
  }
}
