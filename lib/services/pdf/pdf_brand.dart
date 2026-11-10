import 'package:pdf/pdf.dart';

/// CrizaVoise colours for PDFs ("Ink · Paper · Stamp", same as the app).
/// Used whenever the business hasn't picked its own theme colour, so
/// invoices, receipts and reports look like CrizaVoise out of the box.
/// No blue, by design.
class CvPdfColors {
  CvPdfColors._();

  static const ink = PdfColor.fromInt(0xFF121316);
  static const inkSoft = PdfColor.fromInt(0xFF3A3D44);
  static const stamp = PdfColor.fromInt(0xFFC8231C);
  static const stampLight = PdfColor.fromInt(0xFFF2C9C5);
  static const paper = PdfColor.fromInt(0xFFF6F1E7);
  static const clay = PdfColor.fromInt(0xFF9A5530);
  static const olive = PdfColor.fromInt(0xFF55702A);
  static const inkGrey = PdfColor.fromInt(0xFF55585F);
}
