import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to check if biometric auth is enabled.
class IsBiometricEnabledUseCase {
  final AppLockRepository _repository;

  const IsBiometricEnabledUseCase(this._repository);

  Future<bool> call() {
    return _repository.isBiometricEnabled();
  }
}
