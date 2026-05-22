import 'package:expense_management/features/auth/data/models/auth_user_model.dart';

/// Model representing the full authentication response from the API.
class AuthResponseModel {
  final AuthUserModel user;
  final String token;
  final String refreshToken;

  const AuthResponseModel({
    required this.user,
    required this.token,
    required this.refreshToken,
  });

  /// Parse from API JSON response
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      refreshToken: (json['refresh_token'] as String?) ?? '',
    );
  }
}
