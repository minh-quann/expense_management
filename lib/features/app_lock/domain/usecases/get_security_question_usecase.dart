import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to retrieve the security question for PIN recovery.
class GetSecurityQuestionUseCase {
  final AppLockRepository _repository;

  const GetSecurityQuestionUseCase(this._repository);

  Future<String> call() {
    return _repository.getSecurityQuestion();
  }
}
