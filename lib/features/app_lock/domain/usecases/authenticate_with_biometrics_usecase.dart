import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to perform biometric authentication.
class AuthenticateWithBiometricsUseCase {
  final AppLockRepository _repository;

  const AuthenticateWithBiometricsUseCase(this._repository);

  Future<bool> call() {
    return _repository.authenticateWithBiometrics();
  }
}
