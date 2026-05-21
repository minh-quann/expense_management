import 'dart:io';
import 'package:dio/dio.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    // Determine the base URL (uses API_BASE_URL env if provided, otherwise falls back to localhost/10.0.2.2)
    String baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (baseUrl.isEmpty) {
      baseUrl = 'http://localhost:8080/api/v1';
      try {
        if (Platform.isAndroid) {
          baseUrl = 'http://10.0.2.2:8080/api/v1';
        }
      } catch (_) {
        // Platform check can fail on Web platform
        baseUrl = 'http://localhost:8080/api/v1';
      }
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor to add Bearer token to headers and handle refresh token rotation
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthTokenManager.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // If Unauthorized (401), try to refresh token
          if (e.response?.statusCode == 401) {
            final refreshToken = AuthTokenManager.getRefreshToken();
            
            // Avoid refreshing if this error is from /auth/refresh or /auth/login
            final isAuthRoute = e.requestOptions.path.contains('/auth/refresh') ||
                               e.requestOptions.path.contains('/auth/login');
            
            if (refreshToken != null && refreshToken.isNotEmpty && !isAuthRoute) {
              try {
                // Use a separate Dio instance to request a fresh token
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: dio.options.baseUrl,
                    connectTimeout: const Duration(seconds: 10),
                    receiveTimeout: const Duration(seconds: 10),
                  ),
                );
                
                final response = await refreshDio.post('/auth/refresh', data: {
                  'refresh_token': refreshToken,
                });
                
                if (response.statusCode == 200) {
                  final newToken = response.data['token'];
                  final newRefreshToken = response.data['refresh_token'];
                  
                  // Save updated tokens
                  await AuthTokenManager.saveTokens(
                    token: newToken,
                    refreshToken: newRefreshToken,
                  );
                  
                  // Retry the original request with the new authorization token
                  final options = e.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newToken';
                  
                  final cloneResponse = await dio.request(
                    options.path,
                    data: options.data,
                    queryParameters: options.queryParameters,
                    options: Options(
                      method: options.method,
                      headers: options.headers,
                    ),
                  );
                  return handler.resolve(cloneResponse);
                }
              } catch (refreshError) {
                // Failed to refresh - clear auth and let downstream handle logout
                await AuthTokenManager.clearAuthData();
                return handler.next(e);
              }
            }
            
            // No refresh token or auth route failed
            await AuthTokenManager.clearAuthData();
          }
          return handler.next(e);
        },
      ),
    );
  }
}
