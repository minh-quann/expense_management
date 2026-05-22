import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to check if the app lock is enabled.
class IsLockEnabledUseCase {
  final AppLockRepository _repository;

  const IsLockEnabledUseCase(this._repository);

  Future<bool> call() {
    return _repository.isLockEnabled();
  }
}
