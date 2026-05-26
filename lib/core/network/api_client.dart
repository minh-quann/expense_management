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
    }

    // Automatically map localhost to 10.0.2.2 for Android emulator
    try {
      if (Platform.isAndroid && baseUrl.contains('localhost')) {
        baseUrl = baseUrl.replaceFirst('localhost', '10.0.2.2');
      }
    } catch (_) {
      // Platform check can fail on Web platform
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

          if (token == 'dummy_dev_token') {
            final path = options.path;

            if (path.contains('/wallets')) {
              if (options.method == 'GET') {
                return handler.resolve(Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      'id': 'mock-wallet-1',
                      'user_id': 'dev_user_id',
                      'name': 'Ví Tiền Mặt (Mock)',
                      'type': 'CASH',
                      'balance': 10000000.0,
                      'currency': 'VND',
                      'icon': 'account_balance_wallet',
                      'color': '0xFF4CAF50',
                      'exclude_from_total': false,
                      'is_favorite': true,
                    },
                    {
                      'id': 'mock-wallet-2',
                      'user_id': 'dev_user_id',
                      'name': 'Thẻ Ngân Hàng (Mock)',
                      'type': 'BANK',
                      'balance': 50000000.0,
                      'currency': 'VND',
                      'icon': 'credit_card',
                      'color': '0xFF2196F3',
                      'exclude_from_total': false,
                      'is_favorite': false,
                    }
                  ],
                ));
              } else {
                return handler.resolve(Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'message': 'Success (Mock)'},
                ));
              }
            } else if (path.contains('/transactions/statistics')) {
              return handler.resolve(Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'total_income': 15000000.0,
                  'total_expense': 250000.0,
                  'net_balance': 14750000.0,
                  'expense_categories': [
                    {
                      'category_id': 'mock-cat-1',
                      'category_name': 'Ăn uống',
                      'category_icon': 'restaurant',
                      'category_color': '0xFFFF9800',
                      'total_amount': 50000.0,
                      'percentage': 20.0,
                    },
                    {
                      'category_id': 'mock-cat-2',
                      'category_name': 'Di chuyển',
                      'category_icon': 'directions_car',
                      'category_color': '0xFF00BCD4',
                      'total_amount': 200000.0,
                      'percentage': 80.0,
                    }
                  ],
                  'income_categories': [
                    {
                      'category_id': 'mock-cat-3',
                      'category_name': 'Lương',
                      'category_icon': 'attach_money',
                      'category_color': '0xFF4CAF50',
                      'total_amount': 15000000.0,
                      'percentage': 100.0,
                    }
                  ],
                },
              ));
            } else if (path.contains('/transactions')) {
              if (options.method == 'GET') {
                return handler.resolve(Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      'id': 'mock-tx-1',
                      'amount': 50000.0,
                      'type': 'EXPENSE',
                      'category_id': 'mock-cat-1',
                      'category': {
                        'name': 'Ăn uống',
                        'icon': 'restaurant',
                        'color': '0xFFFF9800',
                      },
                      'wallet_id': 'mock-wallet-1',
                      'wallet': {
                        'name': 'Ví Tiền Mặt (Mock)',
                      },
                      'date': DateTime.now().toIso8601String(),
                      'note': 'Ăn trưa (Mock)',
                      'image_url': '',
                      'created_at': DateTime.now().toIso8601String(),
                      'updated_at': DateTime.now().toIso8601String(),
                    },
                    {
                      'id': 'mock-tx-2',
                      'amount': 200000.0,
                      'type': 'EXPENSE',
                      'category_id': 'mock-cat-2',
                      'category': {
                        'name': 'Di chuyển',
                        'icon': 'directions_car',
                        'color': '0xFF00BCD4',
                      },
                      'wallet_id': 'mock-wallet-1',
                      'wallet': {
                        'name': 'Ví Tiền Mặt (Mock)',
                      },
                      'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
                      'note': 'Đổ xăng (Mock)',
                      'image_url': '',
                      'created_at': DateTime.now().toIso8601String(),
                      'updated_at': DateTime.now().toIso8601String(),
                    },
                    {
                      'id': 'mock-tx-3',
                      'amount': 15000000.0,
                      'type': 'INCOME',
                      'category_id': 'mock-cat-3',
                      'category': {
                        'name': 'Lương',
                        'icon': 'attach_money',
                        'color': '0xFF4CAF50',
                      },
                      'wallet_id': 'mock-wallet-2',
                      'wallet': {
                        'name': 'Thẻ Ngân Hàng (Mock)',
                      },
                      'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
                      'note': 'Lương tháng (Mock)',
                      'image_url': '',
                      'created_at': DateTime.now().toIso8601String(),
                      'updated_at': DateTime.now().toIso8601String(),
                    }
                  ],
                ));
              } else {
                return handler.resolve(Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'message': 'Success (Mock)'},
                ));
              }
            } else if (path.contains('/categories')) {
              if (options.method == 'GET') {
                return handler.resolve(Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      'id': 'mock-cat-1',
                      'name': 'Ăn uống',
                      'icon': 'restaurant',
                      'color': '0xFFFF9800',
                      'type': 'EXPENSE',
                      'is_system': true,
                      'is_active': true,
                      'order': 1,
                    },
                    {
                      'id': 'mock-cat-2',
                      'name': 'Di chuyển',
                      'icon': 'directions_car',
                      'color': '0xFF00BCD4',
                      'type': 'EXPENSE',
                      'is_system': true,
                      'is_active': true,
                      'order': 2,
                    },
                    {
                      'id': 'mock-cat-3',
                      'name': 'Lương',
                      'icon': 'attach_money',
                      'color': '0xFF4CAF50',
                      'type': 'INCOME',
                      'is_system': true,
                      'is_active': true,
                      'order': 3,
                    }
                  ],
                ));
              } else {
                return handler.resolve(Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'message': 'Success (Mock)'},
                ));
              }
            } else if (path.contains('/profile')) {
              if (path.contains('/pin/security-question')) {
                return handler.resolve(Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'security_question': 'Màu sắc yêu thích của bạn?'},
                ));
              }
              return handler.resolve(Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'dev_user_id',
                  'email': 'dev@example.com',
                  'display_name': 'Developer',
                  'photo_url': '',
                  'currency_code': 'VND',
                  'phone_number': '0987654321',
                  'address': 'Hanoi, Vietnam',
                  'gender': 'MALE',
                  'created_at': DateTime.now().toIso8601String(),
                },
              ));
            } else {
              return handler.resolve(Response(
                requestOptions: options,
                statusCode: 200,
                data: [],
              ));
            }
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
