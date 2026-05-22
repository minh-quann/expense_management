import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to remove/disable the PIN lock.
class RemovePinUseCase {
  final AppLockRepository _repository;

  const RemovePinUseCase(this._repository);

  Future<void> call(String pin) {
    return _repository.removePin(pin);
  }
}
