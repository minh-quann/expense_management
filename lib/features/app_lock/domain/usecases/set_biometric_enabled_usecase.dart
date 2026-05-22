import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to enable or disable biometric auth.
class SetBiometricEnabledUseCase {
  final AppLockRepository _repository;

  const SetBiometricEnabledUseCase(this._repository);

  Future<void> call(bool enabled) {
    return _repository.setBiometricEnabled(enabled);
  }
}
