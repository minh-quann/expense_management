import 'package:expense_management/features/auth/domain/entities/auth_user.dart';

/// Data model for user, extending the domain entity with JSON serialization.
class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.hasPin,
  });

  /// Create an AuthUserModel from a JSON map returned by the API
  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: (json['display_name'] as String?) ?? '',
      hasPin: (json['has_pin'] as bool?) ?? false,
    );
  }

  /// Convert to JSON map (for potential future use)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'has_pin': hasPin,
    };
  }
}
