import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crizavoise/providers/motion_provider.dart';

/// Short confirmation sound when a document is saved, using the system's own
/// sound (respects the computer's volume and "no sounds" scheme). Only when
/// Settings → Accessibility → "Sound when saved" is on.
void playSavedSound(WidgetRef ref) {
  if (!ref.read(successSoundProvider)) return;
  SystemSound.play(SystemSoundType.alert);
}
