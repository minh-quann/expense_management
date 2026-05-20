import 'package:dio/dio.dart';
import 'package:expense_management/core/network/api_client.dart';
import 'package:expense_management/features/settings/domain/entities/user_profile.dart';

class ProfileRepository {
  final ApiClient _apiClient = ApiClient();

  // Fetch the current user profile from Go backend
  Future<UserProfile> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/profile');
      return UserProfile.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Update profile details (display name, currency, phone number, address, and gender)
  Future<UserProfile> updateProfile({
    required String displayName,
    required String currencyCode,
    required String phoneNumber,
    required String address,
    required String gender,
  }) async {
    try {
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
    } catch (e) {
      rethrow;
    }
  }

  // Upload avatar image to backend and return the updated user profile
  Future<UserProfile> uploadAvatar(String localFilePath) async {
    try {
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
    } catch (e) {
      rethrow;
    }
  }
}
