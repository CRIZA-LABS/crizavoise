import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crizavoise/licensing/license_codec.dart';
import 'dart:convert';

import 'package:crizavoise/licensing/license_service.dart';
import 'package:crizavoise/licensing/online_check.dart';

void main() {
  late SimpleKeyPair pair;
  late List<int> pub;
  const device = '7KQ2-M9XD-4TPA-0WRC';

  setUpAll(() async {
    pair = await Ed25519().newKeyPairFromSeed(List.filled(32, 7));
    pub = (await pair.extractPublicKey()).bytes;
  });

  Future<String> key(LicensePlan plan, {String dev = device, DateTime? issued}) {
    final i = issued ?? DateTime.utc(2026, 11, 1);
    return LicenseCodec.sign(
        LicensePayload(
            id: 'CV-T-1',
            name: 'Shop',
            email: 'a@b.c',
            plan: plan,
            issued: i,
            expires: LicenseCodec.expiryFor(plan, i),
            device: dev),
        pair);
  }

  LicenseService svc(List<LicenseStore> stores, DateTime now) => LicenseService(
      stores: stores, deviceCode: () async => device, publicKey: pub, clock: () => now);

  group('codec', () {
    test('round trip keeps every field', () async {
      final p = await LicenseCodec.verify(await key(LicensePlan.oneYear), pub);
      expect(p!.name, 'Shop');
      expect(p.plan, LicensePlan.oneYear);
      expect(p.expires, DateTime.parse('2027-11-01T23:59:59Z'));
      expect(p.device, device);
    });

    test('tampered payload or signature is rejected', () async {
      final k = await key(LicensePlan.sixMonths);
      final parts = k.split('.');
      final forged = LicenseCodec.sign(
          LicensePayload(
              id: 'x', name: 'x', email: '', plan: LicensePlan.lifetime,
              issued: DateTime.utc(2026), expires: null, device: '*'),
          await Ed25519().newKeyPairFromSeed(List.filled(32, 9)));
      expect(await LicenseCodec.verify('${parts[0]}.${parts[1]}x.${parts[2]}', pub), isNull);
      expect(await LicenseCodec.verify(await forged, pub), isNull);
      expect(await LicenseCodec.verify('nonsense', pub), isNull);
    });

    test('keys survive spaces and line breaks from chat apps', () async {
      final k = await key(LicensePlan.lifetime);
      final messy = '${k.substring(0, 20)}\n ${k.substring(20)}  ';
      expect(await LicenseCodec.verify(messy, pub), isNotNull);
    });

    test('device code is stable, formatted and forgiving to type', () async {
      final a = await DeviceCode.fromMachineId('ABC-123');
      expect(a, await DeviceCode.fromMachineId(' abc-123 '));
      expect(RegExp(r'^[0-9A-Z]{4}(-[0-9A-Z]{4}){3}$').hasMatch(a), isTrue);
      expect(DeviceCode.normalize('7kq2 m9xd-4tpa-owrc'), '7KQ2M9XD4TPA0WRC');
    });

    test('plan lengths', () {
      final d = DateTime.utc(2026, 1, 1);
      expect(LicenseCodec.expiryFor(LicensePlan.sixMonths, d), DateTime.utc(2026, 7, 3));
      expect(LicenseCodec.expiryFor(LicensePlan.oneYear, d), DateTime.utc(2027, 1, 1));
      expect(LicenseCodec.expiryFor(LicensePlan.lifetime, d), isNull);
    });
  });

  group('trial', () {
    test('starts at first launch with 30 days, ends after', () async {
      final store = MemoryLicenseStore();
      final start = DateTime.utc(2026, 11, 10, 9);
      var s = await svc([store], start).load();
      expect(s.kind, LicenseKind.trial);
      expect(s.daysLeft, 30);
      expect(s.showReminder, isFalse);

      s = await svc([store], start.add(const Duration(days: 25))).load();
      expect(s.daysLeft, 5);
      expect(s.showReminder, isTrue);

      s = await svc([store], start.add(const Duration(days: 30, minutes: 1))).load();
      expect(s.kind, LicenseKind.trialEnded);
      expect(s.canCreateDocuments, isFalse);
    });

    test('deleting one store does not restart the trial', () async {
      final a = MemoryLicenseStore(), b = MemoryLicenseStore();
      final start = DateTime.utc(2026, 11, 1);
      await svc([a, b], start).load();
      a.value = null;
      final s = await svc([a, b], start.add(const Duration(days: 31))).load();
      expect(s.kind, LicenseKind.trialEnded);
      expect(a.value, isNotNull, reason: 'missing store is repaired');
    });

    test('setting the clock back does not add days', () async {
      final store = MemoryLicenseStore();
      final start = DateTime.utc(2026, 11, 1);
      await svc([store], start).load();
      await svc([store], start.add(const Duration(days: 29))).load();
      final s = await svc([store], start.add(const Duration(days: 2))).load();
      expect(s.daysLeft, 1);
      expect(s.clockLooksWrong, isTrue);
    });

    test('a hand-edited record ends the trial', () async {
      final store = MemoryLicenseStore('{"b":"{\\"t\\":\\"2099-01-01T00:00:00Z\\"}","m":"x"}');
      final s = await svc([store], DateTime.utc(2026, 11, 10)).load();
      expect(s.kind, LicenseKind.trialEnded);
    });
  });

  group('activation', () {
    test('valid key for this computer activates and survives restarts', () async {
      final store = MemoryLicenseStore();
      final now = DateTime.utc(2026, 11, 10);
      final service = svc([store], now);
      expect(await service.activate(await key(LicensePlan.oneYear)), ActivationResult.activated);
      final s = await svc([store], now).load();
      expect(s.kind, LicenseKind.licensed);
      expect(s.daysLeft, 357);
    });

    test('lifetime never expires; "*" works on any computer', () async {
      final store = MemoryLicenseStore();
      final service = svc([store], DateTime.utc(2026, 11, 10));
      expect(await service.activate(await key(LicensePlan.lifetime, dev: '*')),
          ActivationResult.activated);
      final s = await svc([store], DateTime.utc(2060)).load();
      expect(s.kind, LicenseKind.licensed);
      expect(s.daysLeft, isNull);
      expect(s.showReminder, isFalse);
    });

    test('key for another computer is refused', () async {
      final service = svc([MemoryLicenseStore()], DateTime.utc(2026, 11, 10));
      expect(await service.activate(await key(LicensePlan.oneYear, dev: 'AAAA-BBBB-CCCC-DDDD')),
          ActivationResult.otherDevice);
    });

    test('expired key is refused; an active one later expires', () async {
      final store = MemoryLicenseStore();
      final service = svc([store], DateTime.utc(2026, 11, 10));
      expect(
          await service.activate(
              await key(LicensePlan.sixMonths, issued: DateTime.utc(2025, 1, 1))),
          ActivationResult.expired);
      await service.activate(await key(LicensePlan.sixMonths));
      final s = await svc([store], DateTime.utc(2027, 6, 1)).load();
      expect(s.kind, LicenseKind.licenseExpired);
      expect(s.canCreateDocuments, isFalse);
    });

    test('invalid text is refused and changes nothing', () async {
      final store = MemoryLicenseStore();
      final service = svc([store], DateTime.utc(2026, 11, 10));
      expect(await service.activate('CV1.abc.def'), ActivationResult.invalid);
      expect((await service.load()).kind, LicenseKind.trial);
    });

    test('deactivate returns to the trial state', () async {
      final store = MemoryLicenseStore();
      final service = svc([store], DateTime.utc(2026, 11, 10));
      await service.activate(await key(LicensePlan.oneYear));
      await service.deactivate();
      expect((await service.load()).kind, LicenseKind.trial);
    });
  });

  group('online check (dormant until a server URL is set)', () {
    test('lenient: offline keeps the state; only revoked/moved block; active undoes it', () async {
      final store = MemoryLicenseStore();
      Map<String, dynamic>? answer; // null = offline / no answer
      var calls = 0;
      LicenseService make() => LicenseService(
          stores: [store],
          deviceCode: () async => device,
          publicKey: pub,
          clock: () => DateTime.utc(2026, 11, 10),
          statusFetcher: (id, dev) async {
            calls++;
            return answer == null ? null : {...answer, 'id': id};
          });
      await make().activate(await key(LicensePlan.oneYear));

      expect(await make().checkOnline(), isFalse, reason: 'offline');
      expect((await make().load()).kind, LicenseKind.licensed);

      for (final st in ['active', 'expiring', 'unknown', 'other-device']) {
        answer = {'status': st};
        expect(await make().checkOnline(), isFalse, reason: st);
        expect((await make().load()).kind, LicenseKind.licensed, reason: st);
      }
      expect(calls, 5, reason: 'checks every time it is called (each app start)');

      answer = {'status': 'moved'};
      expect(await make().checkOnline(), isTrue);
      expect((await make().load()).kind, LicenseKind.licenseRevoked);

      answer = null; // offline afterwards: stays as it was
      expect(await make().checkOnline(), isFalse);
      expect((await make().load()).kind, LicenseKind.licenseRevoked);

      answer = {'status': 'active'}; // revoked by mistake, fixed on the server
      expect(await make().checkOnline(), isTrue);
      final s = await make().load();
      expect(s.kind, LicenseKind.licensed);
      expect(s.canCreateDocuments, isTrue);
    });

    test('signed status: genuine, forged and stale answers', () async {
      String b64(List<int> b) => base64Url.encode(b).replaceAll('=', '');
      Future<Map<String, dynamic>> signed(Map<String, dynamic> st, SimpleKeyPair k) async {
        final body = b64(utf8.encode(jsonEncode(st)));
        final sig = await Ed25519().sign(utf8.encode('CVSTAT1|$body'), keyPair: k);
        return {'body': body, 'sig': b64(sig.bytes)};
      }

      final now = DateTime.utc(2026, 11, 10, 12);
      final good = await signed({'id': 'X', 'status': 'revoked', 'ts': now.toIso8601String()}, pair);
      expect((await verifySignedStatus(good, publicKey: pub, now: now))?['status'], 'revoked');
      final other = await Ed25519().newKeyPairFromSeed(List.filled(32, 3));
      expect(await verifySignedStatus(await signed({'id': 'X', 'ts': now.toIso8601String()}, other),
          publicKey: pub, now: now), isNull);
      expect(await verifySignedStatus(good, publicKey: pub, now: now.add(const Duration(days: 5))),
          isNull, reason: 'replayed old answer');
    });
  });
}
