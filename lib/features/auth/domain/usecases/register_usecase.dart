import 'package:expense_management/features/auth/domain/repositories/auth_repository.dart';

/// Use case for registering a new account with email and password.
class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<AuthResult> call(String email, String password, String displayName) {
    return _repository.registerWithEmail(email, password, displayName);
  }
}
