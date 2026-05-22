import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/features/app_lock/data/services/app_lock_service.dart';
import 'package:expense_management/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:expense_management/features/auth/domain/entities/auth_user.dart';
import 'package:expense_management/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
/// Coordinates between the remote data source and local token storage.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AppLockService _appLockService;

  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    AppLockService? appLockService,
  })  : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl(),
        _appLockService = appLockService ?? AppLockService();

  /// Save auth tokens and user data to local storage after successful authentication
  Future<AuthUser> _persistAuthData(
    String token,
    String refreshToken,
    AuthUser user,
    bool hasPin,
  ) async {
    await AuthTokenManager.saveAuthData(
      token: token,
      refreshToken: refreshToken,
      userId: user.id,
      email: user.email,
      name: user.displayName,
    );
    await _appLockService.syncLockState(hasPin);
    return user;
  }

  @override
  Future<AuthResult> loginWithEmail(String email, String password) async {
    final response = await _remoteDataSource.loginWithEmail(email, password);
    await _persistAuthData(
      response.token,
      response.refreshToken,
      response.user,
      response.user.hasPin,
    );
    return AuthResult(
      user: response.user,
      token: response.token,
      refreshToken: response.refreshToken,
    );
  }

  @override
  Future<AuthResult> registerWithEmail(String email, String password, String displayName) async {
    final response = await _remoteDataSource.registerWithEmail(email, password, displayName);
    await _persistAuthData(
      response.token,
      response.refreshToken,
      response.user,
      response.user.hasPin,
    );
    return AuthResult(
      user: response.user,
      token: response.token,
      refreshToken: response.refreshToken,
    );
  }

  @override
  Future<AuthResult> loginWithGoogle(String idToken) async {
    final response = await _remoteDataSource.loginWithGoogle(idToken);
    await _persistAuthData(
      response.token,
      response.refreshToken,
      response.user,
      response.user.hasPin,
    );
    return AuthResult(
      user: response.user,
      token: response.token,
      refreshToken: response.refreshToken,
    );
  }

  @override
  Future<ForgotPasswordResult> forgotPassword(String email) async {
    final token = await _remoteDataSource.forgotPassword(email);
    return ForgotPasswordResult(token: token);
  }

  @override
  Future<String> resetPassword(String email, String token, String newPassword) async {
    return await _remoteDataSource.resetPassword(email, token, newPassword);
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _remoteDataSource.logout(refreshToken);
    } catch (_) {
      // Ignore API logout failures so offline users can still logout locally
    }
    await AuthTokenManager.clearAuthData();
  }
}
