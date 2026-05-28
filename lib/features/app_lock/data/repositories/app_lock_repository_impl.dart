import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

class AppLockRepositoryImpl implements AppLockRepository {
  String get _pinKey {
    final userId = AuthTokenManager.getUserId();
    return 'app_lock_pin_$userId';
  }

  String get _lockEnabledKey {
    final userId = AuthTokenManager.getUserId();
    return 'app_lock_enabled_$userId';
  }

  String get _biometricEnabledKey {
    final userId = AuthTokenManager.getUserId();
    return 'biometric_enabled_$userId';
  }

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  AppLockRepositoryImpl({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  @override
  Future<void> savePin(String pin, {required String question, required String answer}) async {
    await ApiClient().dio.post('/profile/pin', data: {
      'pin': pin,
      'security_question': question,
      'security_answer': answer,
    });

    await _secureStorage.write(key: _pinKey, value: pin);
    await _secureStorage.write(key: _lockEnabledKey, value: 'true');
  }

  @override
  Future<String?> getPin() async {
    return await _secureStorage.read(key: _pinKey);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final storedPin = await getPin();
    if (storedPin != null) {
      if (storedPin == pin) {
        return true;
      }
    }

    try {
      final response = await ApiClient().dio.post('/profile/pin/verify', data: {
        'pin': pin,
      });
      if (response.statusCode == 200 && response.data['verified'] == true) {
        await _secureStorage.write(key: _pinKey, value: pin);
        await _secureStorage.write(key: _lockEnabledKey, value: 'true');
        return true;
      }
    } catch (_) {}
    return false;
  }

  @override
  Future<void> removePin(String pin) async {
    await ApiClient().dio.delete('/profile/pin', data: {
      'pin': pin,
    });

    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.write(key: _lockEnabledKey, value: 'false');
    await _secureStorage.write(key: _biometricEnabledKey, value: 'false');
  }

  @override
  Future<String> getSecurityQuestion() async {
    final response = await ApiClient().dio.get('/profile/pin/security-question');
    return response.data['security_question'] as String;
  }

  @override
  Future<void> resetPin(String answer, String newPin) async {
    await ApiClient().dio.post('/profile/pin/reset', data: {
      'security_answer': answer,
      'new_pin': newPin,
    });

    await _secureStorage.write(key: _pinKey, value: newPin);
    await _secureStorage.write(key: _lockEnabledKey, value: 'true');
  }

  @override
  Future<bool> isLockEnabled() async {
    if (!AuthTokenManager.isLoggedIn()) {
      return false;
    }
    final pin = await _secureStorage.read(key: _pinKey);
    if (pin == null || pin.isEmpty) {
      return false;
    }
    final value = await _secureStorage.read(key: _lockEnabledKey);
    return value == 'true';
  }

  @override
  Future<void> syncLockState(bool hasPin) async {
    if (!AuthTokenManager.isLoggedIn()) return;
    await _secureStorage.write(
      key: _lockEnabledKey,
      value: hasPin ? 'true' : 'false',
    );
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuth && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Xác thực để mở khóa ứng dụng',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
