import 'package:dio/dio.dart';
import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/features/auth/data/models/auth_response_model.dart';

/// Remote data source responsible for all auth-related API calls.
/// This is the ONLY place where Dio is used for auth operations.
abstract class AuthRemoteDataSource {
  /// POST /auth/login
  Future<AuthResponseModel> loginWithEmail(String email, String password);

  /// POST /auth/register
  Future<AuthResponseModel> registerWithEmail(String email, String password, String displayName);

  /// POST /auth/google
  Future<AuthResponseModel> loginWithGoogle(String idToken);

  /// POST /auth/forgot-password
  Future<String> forgotPassword(String email);

  /// POST /auth/reset-password
  Future<String> resetPassword(String email, String token, String newPassword);

  /// POST /auth/logout
  Future<void> logout(String refreshToken);
}

/// Implementation of [AuthRemoteDataSource] using Dio HTTP client.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  @override
  Future<AuthResponseModel> loginWithEmail(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> registerWithEmail(String email, String password, String displayName) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'display_name': displayName,
    });
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> loginWithGoogle(String idToken) async {
    final response = await _dio.post('/auth/google', data: {
      'id_token': idToken,
    });
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<String> forgotPassword(String email) async {
    final response = await _dio.post('/auth/forgot-password', data: {
      'email': email,
    });
    return (response.data['token'] as String?) ?? '';
  }

  @override
  Future<String> resetPassword(String email, String token, String newPassword) async {
    final response = await _dio.post('/auth/reset-password', data: {
      'email': email,
      'token': token,
      'new_password': newPassword,
    });
    return (response.data['message'] as String?) ?? 'Đặt lại mật khẩu thành công';
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _dio.post('/auth/logout', data: {
      'refresh_token': refreshToken,
    });
  }
}
