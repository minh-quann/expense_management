import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';

/// Service for managing app lock settings and biometric authentication.
/// Stores PIN securely and checks device biometric capabilities.
class AppLockService {
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

  AppLockService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  // --- PIN Management ---

  /// Save PIN code securely on both local storage and backend database.
  Future<void> savePin(String pin, {required String question, required String answer}) async {
    // Call backend API to set PIN and security question
    await ApiClient().dio.post('/profile/pin', data: {
      'pin': pin,
      'security_question': question,
      'security_answer': answer,
    });

    // If successful, save locally
    await _secureStorage.write(key: _pinKey, value: pin);
    await _secureStorage.write(key: _lockEnabledKey, value: 'true');
  }

  /// Get stored PIN code
  Future<String?> getPin() async {
    return await _secureStorage.read(key: _pinKey);
  }

  /// Verify if the entered PIN matches stored PIN (local or backend)
  Future<bool> verifyPin(String pin) async {
    final storedPin = await getPin();
    if (storedPin != null) {
      if (storedPin == pin) {
        return true;
      }
    }

    // Try validating with backend
    try {
      final response = await ApiClient().dio.post('/profile/pin/verify', data: {
        'pin': pin,
      });
      if (response.statusCode == 200 && response.data['verified'] == true) {
        // Sync to local secure storage
        await _secureStorage.write(key: _pinKey, value: pin);
        await _secureStorage.write(key: _lockEnabledKey, value: 'true');
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Remove PIN and disable app lock (local and backend)
  Future<void> removePin(String pin) async {
    // Call backend API to disable PIN
    await ApiClient().dio.delete('/profile/pin', data: {
      'pin': pin,
    });

    // If successful, clear local settings
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.write(key: _lockEnabledKey, value: 'false');
    await _secureStorage.write(key: _biometricEnabledKey, value: 'false');
  }

  /// Fetch security question from backend
  Future<String> getSecurityQuestion() async {
    final response = await ApiClient().dio.get('/profile/pin/security-question');
    return response.data['security_question'] as String;
  }

  /// Reset PIN using security answer on backend
  Future<void> resetPin(String answer, String newPin) async {
    await ApiClient().dio.post('/profile/pin/reset', data: {
      'security_answer': answer,
      'new_pin': newPin,
    });

    // If successful, update local PIN
    await _secureStorage.write(key: _pinKey, value: newPin);
    await _secureStorage.write(key: _lockEnabledKey, value: 'true');
  }

  // --- Lock State ---

  /// Check if app lock is enabled
  Future<bool> isLockEnabled() async {
    if (!AuthTokenManager.isLoggedIn()) {
      return false;
    }
    final value = await _secureStorage.read(key: _lockEnabledKey);
    return value == 'true';
  }

  /// Sync lock state from backend
  Future<void> syncLockState(bool hasPin) async {
    if (!AuthTokenManager.isLoggedIn()) return;
    await _secureStorage.write(
      key: _lockEnabledKey,
      value: hasPin ? 'true' : 'false',
    );
  }

  // --- Biometric Management ---

  /// Check if biometric authentication is enabled by user
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  /// Enable or disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuth && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Get available biometric types on device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Authenticate using biometrics (fingerprint / Face ID)
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
