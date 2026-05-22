import 'package:expense_management/features/auth/domain/entities/auth_user.dart';

/// Result object returned after successful authentication (login/register/google).
class AuthResult {
  final AuthUser user;
  final String token;
  final String refreshToken;

  const AuthResult({
    required this.user,
    required this.token,
    required this.refreshToken,
  });
}

/// Result object returned after requesting forgot password.
class ForgotPasswordResult {
  final String token;

  const ForgotPasswordResult({required this.token});
}

/// Abstract repository contract for authentication operations.
/// Implementations live in the data layer.
abstract class AuthRepository {
  /// Authenticate with email and password
  Future<AuthResult> loginWithEmail(String email, String password);

  /// Register a new account with email, password, and display name
  Future<AuthResult> registerWithEmail(String email, String password, String displayName);

  /// Authenticate with Google ID token
  Future<AuthResult> loginWithGoogle(String idToken);

  /// Request a password reset code for the given email
  Future<ForgotPasswordResult> forgotPassword(String email);

  /// Reset password using a verification token
  Future<String> resetPassword(String email, String token, String newPassword);

  /// Logout and invalidate the current refresh token
  Future<void> logout(String refreshToken);
}
