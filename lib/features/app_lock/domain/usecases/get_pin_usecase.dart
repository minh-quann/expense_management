import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to retrieve the stored PIN.
class GetPinUseCase {
  final AppLockRepository _repository;

  const GetPinUseCase(this._repository);

  Future<String?> call() {
    return _repository.getPin();
  }
}
