import 'package:flutter_test/flutter_test.dart';

import 'package:crizavoise/services/escpos/esc_pos_encoder.dart';

void main() {
  test('starts with ESC @ (initialise)', () {
    expect(EscPosEncoder(lineChars: 32).bytes, [0x1B, 0x40]);
  });

  test('text: alignment, bold, size, font, then reset', () {
    final e = EscPosEncoder(lineChars: 48)
      ..text('Hi', align: EscAlign.center, bold: true, height: 2, width: 2, fontB: true);
    expect(e.bytes.sublist(2), [
      0x1B, 0x61, 1, // center
      0x1B, 0x45, 1, // bold
      0x1B, 0x4D, 1, // font B
      0x1D, 0x21, 0x11, // double width + height
      0x48, 0x69, 0x0A, // "Hi" + LF
      0x1B, 0x45, 0, 0x1D, 0x21, 0, 0x1B, 0x4D, 0, 0x1B, 0x61, 0, // reset
    ]);
  });

  test('never emits FS . (the stray-dot bug)', () {
    final e = EscPosEncoder(lineChars: 32)..text('Total 100')..hr()..cut();
    final b = e.bytes;
    for (var i = 0; i + 1 < b.length; i++) {
      expect(b[i] == 0x1C && b[i + 1] == 0x2E, isFalse);
    }
  });

  test('rule is full width; reverse feed and cut', () {
    final e = EscPosEncoder(lineChars: 32)..hr()..reverseFeed(3)..cut();
    final b = e.bytes;
    expect(b.where((x) => x == 0x2D).length, 32);
    expect(b.sublist(b.length - 3), [0x1D, 0x56, 0x00]);
    expect(b.indexOf(0x65) > 0 && b[b.indexOf(0x65) + 1] == 3, isTrue);
  });

  test('text cannot inject printer commands; unsupported chars become ?', () {
    expect(EscPosEncoder.encodeText('A\x1B@B'), [0x41, 0x40, 0x42]);
    expect(EscPosEncoder.encodeText('₹5'), [0x3F, 0x35]);
    expect(EscPosEncoder.encodeText('café'), [0x63, 0x61, 0x66, 0xE9]);
  });
}
