import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to reset the PIN using the security question's answer.
class ResetPinUseCase {
  final AppLockRepository _repository;

  const ResetPinUseCase(this._repository);

  Future<void> call(String answer, String newPin) {
    return _repository.resetPin(answer, newPin);
  }
}
