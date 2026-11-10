import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Read-only PDF preview of [bytes] (continuous pages, zoomable), built on
/// the `printing` package (Apache-2.0) — replaces the commercially licensed
/// Syncfusion viewer. The surrounding dialog provides print/download/close,
/// so PdfPreview's own toolbar is switched off.
class PdfBytesViewer extends StatelessWidget {
  final Uint8List bytes;
  const PdfBytesViewer(this.bytes, {super.key});

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      build: (_) async => bytes,
      useActions: false,
      allowPrinting: false,
      allowSharing: false,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      maxPageWidth: 820,
      scrollViewDecoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLowest),
      pdfPreviewPageDecoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      loadingWidget: const Center(child: CircularProgressIndicator()),
    );
  }
}
