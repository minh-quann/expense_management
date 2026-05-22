import 'package:expense_management/features/auth/domain/repositories/auth_repository.dart';

/// Use case for requesting a password reset code via email.
class ForgotPasswordUseCase {
  final AuthRepository _repository;

  const ForgotPasswordUseCase(this._repository);

  Future<ForgotPasswordResult> call(String email) {
    return _repository.forgotPassword(email);
  }
}
