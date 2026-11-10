import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart';

import 'package:crizavoise/l10n/app_localizations.dart';

/// Voice input using the operating system's own dictation (Windows voice
/// typing, Win + H). CrizaVoise records nothing itself: Windows types the
/// words into the focused field. Available on Windows 10/11 only.
class VoiceTyping {
  VoiceTyping._();

  static bool get isSupported => Platform.isWindows;

  /// Opens Windows voice typing for whatever field currently has focus.
  static void start() {
    if (!isSupported) return;
    using((arena) {
      final inputs = arena<INPUT>(4);
      void key(int i, int vk, {bool up = false}) {
        final k = inputs[i];
        k.type = INPUT_KEYBOARD;
        k.ki.wVk = vk;
        k.ki.dwFlags = up ? KEYEVENTF_KEYUP : 0;
      }

      key(0, VK_LWIN);
      key(1, 0x48); // H
      key(2, 0x48, up: true);
      key(3, VK_LWIN, up: true);
      SendInput(4, inputs, sizeOf<INPUT>());
    });
  }
}

/// Mic button for a text field: focuses the field, then opens voice typing.
class VoiceTypingButton extends StatelessWidget {
  final FocusNode focusNode;
  const VoiceTypingButton({super.key, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    if (!VoiceTyping.isSupported) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: l10n.voiceTypingTooltip,
      icon: const Icon(Icons.mic_none_rounded, size: 18),
      onPressed: () async {
        focusNode.requestFocus();
        // Let the field take focus before Windows attaches dictation to it.
        await Future<void>.delayed(const Duration(milliseconds: 150));
        VoiceTyping.start();
        HapticFeedback.selectionClick();
      },
    );
  }
}
