import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Reduce motion" (Settings → Accessibility). When on — or when the OS asks
/// for reduced motion — animations are turned down to instant changes or
/// short fades (see CvMotion.scaled / MediaQuery.disableAnimations).
final reduceMotionProvider = StateProvider<bool>((ref) => false);

/// "Sound when saved" (Settings → Accessibility). Off by default.
final successSoundProvider = StateProvider<bool>((ref) => false);
