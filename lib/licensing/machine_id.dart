import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Reads the operating system's own machine identifier. It survives
/// reinstalling CrizaVoise, so a licence stays tied to the computer.
/// Returns null when it can't be read (the caller falls back to the
/// installation ID).
class MachineId {
  MachineId._();

  static Future<String?> read() async {
    try {
      if (Platform.isWindows) return _windows();
      if (Platform.isLinux) {
        for (final p in ['/etc/machine-id', '/var/lib/dbus/machine-id']) {
          final f = File(p);
          if (await f.exists()) {
            final v = (await f.readAsString()).trim();
            if (v.isNotEmpty) return v;
          }
        }
      }
      if (Platform.isMacOS) {
        final r = await Process.run('ioreg', ['-rd1', '-c', 'IOPlatformExpertDevice']);
        final m = RegExp(r'"IOPlatformUUID"\s*=\s*"([^"]+)"').firstMatch('${r.stdout}');
        return m?.group(1);
      }
    } catch (_) {}
    return null;
  }

  static String? _windows() => WindowsRegistry.readString(
      HKEY_LOCAL_MACHINE, r'SOFTWARE\Microsoft\Cryptography', 'MachineGuid',
      wow64: true);
}

/// Tiny wrapper over the Win32 registry string API (no child processes, so
/// no console windows flash up).
class WindowsRegistry {
  WindowsRegistry._();

  static String? readString(int root, String subKey, String name, {bool wow64 = false}) {
    return using((arena) {
      final size = arena<Uint32>()..value = 1024;
      final buf = arena<Uint16>(512);
      final r = RegGetValue(
          root,
          subKey.toNativeUtf16(allocator: arena),
          name.toNativeUtf16(allocator: arena),
          RRF_RT_REG_SZ | (wow64 ? RRF_SUBKEY_WOW6464KEY : 0),
          nullptr,
          buf,
          size);
      if (r != ERROR_SUCCESS) return null;
      return buf.cast<Utf16>().toDartString();
    });
  }

  static bool writeString(int root, String subKey, String name, String value) {
    return using((arena) {
      final data = value.toNativeUtf16(allocator: arena);
      final r = RegSetKeyValue(root, subKey.toNativeUtf16(allocator: arena),
          name.toNativeUtf16(allocator: arena), REG_SZ, data, (value.length + 1) * 2);
      return r == ERROR_SUCCESS;
    });
  }
}
