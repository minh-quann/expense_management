import 'package:expense_management/features/settings/domain/entities/user_profile.dart';

abstract class ProfileRepository {
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
