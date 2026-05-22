import 'package:expense_management/features/auth/domain/repositories/auth_repository.dart';

/// Use case for logging out and invalidating refresh token.
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  Future<void> call(String refreshToken) {
    return _repository.logout(refreshToken);
  }
}
