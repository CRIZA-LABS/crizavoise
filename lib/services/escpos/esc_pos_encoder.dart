import 'dart:convert';

/// Text alignment on the receipt.
enum EscAlign { left, center, right }

/// Minimal ESC/POS byte encoder for CrizaVoise receipts, written from the
/// public ESC/POS command set (Epson-compatible). Replaces an LGPL encoder so
/// the app keeps a permissive licence. Only what receipts need: aligned/bold/
/// sized text, rules, reverse feed and cut.
///
/// Unlike the old library it never emits `FS .` (Cancel Kanji), so no stray
/// dots appear on printers that don't understand it.
class EscPosEncoder {
  /// Characters per line for the paper: 58 mm = 32, 80 mm = 48 (font A).
  final int lineChars;
  final List<int> _bytes = [];

  EscPosEncoder({required this.lineChars}) {
    _bytes.addAll(const [0x1B, 0x40]); // ESC @ — initialise printer
  }

  List<int> get bytes => List.unmodifiable(_bytes);

  static const _esc = 0x1B, _gs = 0x1D, _lf = 0x0A;

  /// One line of text.
  /// [height]/[width] are the character magnification (1 or 2).
  /// [fontB] selects the smaller font B.
  void text(String text,
      {EscAlign align = EscAlign.left,
      bool bold = false,
      int height = 1,
      int width = 1,
      bool fontB = false}) {
    final h = height.clamp(1, 8) - 1, w = width.clamp(1, 8) - 1;
    _bytes
      ..addAll([_esc, 0x61, align.index]) // ESC a n — justification
      ..addAll([_esc, 0x45, bold ? 1 : 0]) // ESC E n — emphasis
      ..addAll([_esc, 0x4D, fontB ? 1 : 0]) // ESC M n — font
      ..addAll([_gs, 0x21, (w << 4) | h]) // GS ! n — character size
      ..addAll(encodeText(text))
      ..add(_lf);
    // Back to defaults so the next line starts clean.
    _bytes
      ..addAll([_esc, 0x45, 0])
      ..addAll([_gs, 0x21, 0])
      ..addAll([_esc, 0x4D, 0])
      ..addAll([_esc, 0x61, 0]);
  }

  /// A full-width rule of [ch] characters.
  void hr({String ch = '-'}) => text(ch * lineChars);

  /// ESC e n — feed the paper back [lines] lines (shrinks the gap before cut).
  void reverseFeed(int lines) => _bytes.addAll([_esc, 0x65, lines.clamp(0, 255)]);

  /// Feed past the cutter, then GS V 0 — full cut.
  void cut({int feedLines = 5}) {
    for (var i = 0; i < feedLines; i++) {
      _bytes.add(_lf);
    }
    _bytes.addAll([_gs, 0x56, 0x00]);
  }

  /// Printer code page 437/Latin-1 for ASCII and Latin-1 text; anything the
  /// printer can't show becomes '?' instead of corrupting the stream.
  /// Control bytes are dropped so text can never inject commands.
  static List<int> encodeText(String s) {
    final out = <int>[];
    for (final r in s.runes) {
      if (r == 0x0A || r == 0x0D) continue;
      if (r < 0x20 || r == 0x7F) continue;
      out.add(r < 0x100 ? r : 0x3F);
    }
    return out.isEmpty ? <int>[] : latin1.decode(out).codeUnits;
  }
}
