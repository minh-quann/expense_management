import 'package:expense_management/features/auth/domain/repositories/auth_repository.dart';

/// Use case for Google sign-in authentication.
class GoogleLoginUseCase {
  final AuthRepository _repository;

  const GoogleLoginUseCase(this._repository);

  Future<AuthResult> call(String idToken) {
    return _repository.loginWithGoogle(idToken);
  }
}
