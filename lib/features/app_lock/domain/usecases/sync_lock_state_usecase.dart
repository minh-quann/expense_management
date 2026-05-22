import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to sync app lock status flag across shared preferences.
class SyncLockStateUseCase {
  final AppLockRepository _repository;

  const SyncLockStateUseCase(this._repository);

  Future<void> call(bool hasPin) {
    return _repository.syncLockState(hasPin);
  }
}
