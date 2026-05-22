import 'package:equatable/equatable.dart';

/// Pure domain entity representing an authenticated user.
/// This class has no dependency on any framework or data source.
class AuthUser extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final bool hasPin;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.hasPin = false,
  });

  @override
  List<Object?> get props => [id, email, displayName, hasPin];
}
