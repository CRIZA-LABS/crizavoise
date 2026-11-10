import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:crizavoise/services/image_import_service.dart';

Uint8List _png(int w, int h, {bool transparent = false}) {
  final image = img.Image(width: w, height: h, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(200, 30, 30, 255));
  if (transparent) image.setPixelRgba(0, 0, 0, 0, 0, 0);
  return img.encodePng(image);
}

Uint8List _jpg(int w, int h) {
  final image = img.Image(width: w, height: h);
  // noisy content so the JPEG is photo-like
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      image.setPixelRgb(x, y, (x * 7) % 256, (y * 13) % 256, (x * y) % 256);
    }
  }
  return img.encodeJpg(image, quality: 95);
}

void main() {
  group('ImageImportService', () {
    test('large logos are accepted and resized to the logo size (was rejected above 1080px)', () {
      final r = ImageImportService.processSync(_jpg(4000, 3000), ImageKind.logo)!;
      expect(r.originalWidth, 4000);
      expect(r.originalHeight, 3000);
      expect(r.width, 1024);
      expect(r.height, 768); // aspect ratio kept
      expect(r.wasResized, isTrue);
    });

    test('tall images are limited by their height', () {
      final r = ImageImportService.processSync(_png(500, 3000), ImageKind.logo)!;
      expect(r.height, 1024);
      expect(r.width, closeTo(171, 1));
    });

    test('images within the limit are never upscaled', () {
      final r = ImageImportService.processSync(_png(300, 200), ImageKind.logo)!;
      expect(r.width, 300);
      expect(r.height, 200);
      expect(r.wasResized, isFalse);
      expect(r.longestSide < ImageKind.logo.recommendedMin, isTrue); // UI warns: may be blurry
    });

    test('transparency is kept as PNG', () {
      final r = ImageImportService.processSync(_png(2000, 2000, transparent: true), ImageKind.logo)!;
      expect(r.hasTransparency, isTrue);
      expect(img.findFormatForData(r.bytes), img.ImageFormat.png);
    });

    test('each kind has its own size', () {
      final big = _jpg(5000, 1000);
      expect(ImageImportService.processSync(big, ImageKind.signature)!.width, 1000);
      expect(ImageImportService.processSync(big, ImageKind.watermark)!.width, 1600);
    });

    test('unreadable data returns null instead of throwing', () {
      expect(ImageImportService.processSync(Uint8List.fromList([1, 2, 3, 4]), ImageKind.logo), isNull);
    });

    test('result bytes decode again (what PDFs and the app read)', () {
      final r = ImageImportService.processSync(_jpg(3000, 3000), ImageKind.logo)!;
      final again = img.decodeImage(r.bytes)!;
      expect(again.width, r.width);
      expect(r.bytes.length, lessThan(2 * 1024 * 1024));
    });
  });
}
