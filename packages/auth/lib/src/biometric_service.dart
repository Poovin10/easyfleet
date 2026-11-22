import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService(LocalAuthentication(), const FlutterSecureStorage());
});

/// Local biometric unlock around the Supabase session.
/// Passkeys/WebAuthn from WonderMove are intentionally not ported.
class BiometricService {
  BiometricService(this._localAuth, this._storage);

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _storage;

  static const _enabledKey = 'biometric_unlock_enabled';
  static const _reason = 'Unlock EasyFleet';

  Future<bool> isSupported() async {
    try {
      return await _localAuth.canCheckBiometrics &&
          await _localAuth.isDeviceSupported();
    } on Object catch (_) {
      return false;
    }
  }

  Future<bool> isEnabled() async {
    return (await _storage.read(key: _enabledKey)) == 'true';
  }

  Future<void> setEnabled(bool value) async {
    await _storage.write(key: _enabledKey, value: value.toString());
  }

  Future<bool> unlock() async {
    if (!await isEnabled()) return true;
    try {
      return await _localAuth.authenticate(
        localizedReason: _reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on Object catch (e) {
      debugPrint('Biometric unlock failed: $e');
      return false;
    }
  }
}
