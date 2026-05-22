import 'package:dio/dio.dart';
import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/features/settings/domain/entities/user_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile({
    required String displayName,
    required String currencyCode,
    required String phoneNumber,
    required String address,
    required String gender,
  });
  Future<UserProfile> uploadAvatar(String localFilePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<UserProfile> getProfile() async {
    final response = await _apiClient.dio.get('/profile');
    return UserProfile.fromJson(response.data);
  }

  @override
  Future<UserProfile> updateProfile({
    required String displayName,
    required String currencyCode,
    required String phoneNumber,
    required String address,
    required String gender,
  }) async {
    final response = await _apiClient.dio.put(
      '/profile',
      data: {
        'display_name': displayName,
        'currency_code': currencyCode,
        'phone_number': phoneNumber,
        'address': address,
        'gender': gender,
      },
    );
    return UserProfile.fromJson(response.data);
  }

  @override
  Future<UserProfile> uploadAvatar(String localFilePath) async {
    final fileName = localFilePath.split('/').last;
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        localFilePath,
        filename: fileName,
      ),
    });

    final response = await _apiClient.dio.post(
      '/profile/avatar',
      data: formData,
    );
    return UserProfile.fromJson(response.data);
  }
}
