import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';
import 'package:expense_management/features/app_lock/data/repositories/app_lock_repository_impl.dart';

/// Service for managing app lock settings and biometric authentication.
/// Stores PIN securely and checks device biometric capabilities.
/// Implements [AppLockRepository] to align with Clean Architecture.
class AppLockService implements AppLockRepository {
  final AppLockRepository _repository;

  AppLockService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
    AppLockRepository? repository,
  }) : _repository = repository ?? AppLockRepositoryImpl(
          secureStorage: secureStorage,
          localAuth: localAuth,
        );

  @override
  Future<void> savePin(String pin, {required String question, required String answer}) {
    return _repository.savePin(pin, question: question, answer: answer);
  }

  @override
  Future<String?> getPin() {
    return _repository.getPin();
  }

  @override
  Future<bool> verifyPin(String pin) {
    return _repository.verifyPin(pin);
  }

  @override
  Future<void> removePin(String pin) {
    return _repository.removePin(pin);
  }

  @override
  Future<String> getSecurityQuestion() {
    return _repository.getSecurityQuestion();
  }

  @override
  Future<void> resetPin(String answer, String newPin) {
    return _repository.resetPin(answer, newPin);
  }

  @override
  Future<bool> isLockEnabled() {
    return _repository.isLockEnabled();
  }

  @override
  Future<void> syncLockState(bool hasPin) {
    return _repository.syncLockState(hasPin);
  }

  @override
  Future<bool> isBiometricEnabled() {
    return _repository.isBiometricEnabled();
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) {
    return _repository.setBiometricEnabled(enabled);
  }

  @override
  Future<bool> isBiometricAvailable() {
    return _repository.isBiometricAvailable();
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() {
    return _repository.getAvailableBiometrics();
  }

  @override
  Future<bool> authenticateWithBiometrics() {
    return _repository.authenticateWithBiometrics();
  }
}
