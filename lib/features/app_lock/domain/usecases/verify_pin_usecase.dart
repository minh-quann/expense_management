import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to verify if the entered PIN matches the stored PIN.
class VerifyPinUseCase {
  final AppLockRepository _repository;

  const VerifyPinUseCase(this._repository);

  Future<bool> call(String pin) {
    return _repository.verifyPin(pin);
  }
}
