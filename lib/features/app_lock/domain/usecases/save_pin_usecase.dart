import 'package:expense_management/features/app_lock/domain/repositories/app_lock_repository.dart';

/// Use case to securely save a new PIN with security question.
class SavePinUseCase {
  final AppLockRepository _repository;

  const SavePinUseCase(this._repository);

  Future<void> call(String pin, {required String question, required String answer}) {
    return _repository.savePin(pin, question: question, answer: answer);
  }
}
