import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save authentication details
  static Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String email,
    required String name,
  }) async {
    await init();
    await _prefs!.setString(_tokenKey, token);
    await _prefs!.setString(_refreshTokenKey, refreshToken);
    await _prefs!.setString(_userIdKey, userId);
    await _prefs!.setString(_userEmailKey, email);
    await _prefs!.setString(_userNameKey, name);
  }

  // Save updated tokens (used for rotation)
  static Future<void> saveTokens({
    required String token,
    required String refreshToken,
  }) async {
    await init();
    await _prefs!.setString(_tokenKey, token);
    await _prefs!.setString(_refreshTokenKey, refreshToken);
  }

  // Get token
  static String? getToken() {
    return _prefs?.getString(_tokenKey);
  }

  // Get refresh token
  static String? getRefreshToken() {
    return _prefs?.getString(_refreshTokenKey);
  }

  // Get userId
  static String getUserId() {
    return _prefs?.getString(_userIdKey) ?? '';
  }

  // Get email
  static String getEmail() {
    return _prefs?.getString(_userEmailKey) ?? '';
  }

  // Get name
  static String getName() {
    return _prefs?.getString(_userNameKey) ?? '';
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear authentication data on logout
  static Future<void> clearAuthData() async {
    await init();
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_refreshTokenKey);
    await _prefs!.remove(_userIdKey);
    await _prefs!.remove(_userEmailKey);
    await _prefs!.remove(_userNameKey);
  }
}
