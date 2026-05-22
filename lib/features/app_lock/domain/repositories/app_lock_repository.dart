import 'package:local_auth/local_auth.dart';

abstract class AppLockRepository {
  Future<void> savePin(String pin, {required String question, required String answer});
  Future<String?> getPin();
  Future<bool> verifyPin(String pin);
  Future<void> removePin(String pin);
  Future<String> getSecurityQuestion();
  Future<void> resetPin(String answer, String newPin);
  Future<bool> isLockEnabled();
  Future<void> syncLockState(bool hasPin);
  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricAvailable();
  Future<List<BiometricType>> getAvailableBiometrics();
  Future<bool> authenticateWithBiometrics();
}
