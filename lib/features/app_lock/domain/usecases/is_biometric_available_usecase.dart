import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to check if the device supports biometric auth.
class IsBiometricAvailableUseCase {
  final AppLockRepository _repository;

  const IsBiometricAvailableUseCase(this._repository);

  Future<bool> call() {
    return _repository.isBiometricAvailable();
  }
}
