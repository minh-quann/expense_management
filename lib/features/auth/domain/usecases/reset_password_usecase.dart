import 'package:expense_management/features/auth/domain/repositories/auth_repository.dart';

/// Use case for resetting password with a verification token.
class ResetPasswordUseCase {
  final AuthRepository _repository;

  const ResetPasswordUseCase(this._repository);

  Future<String> call(String email, String token, String newPassword) {
    return _repository.resetPassword(email, token, newPassword);
  }
}
