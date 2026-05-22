import 'package:expense_management/features/auth/domain/repositories/auth_repository.dart';

/// Use case for email/password login.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<AuthResult> call(String email, String password) {
    return _repository.loginWithEmail(email, password);
  }
}
