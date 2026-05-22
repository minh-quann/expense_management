import 'package:expense_management/features/settings/domain/entities/user_profile.dart';
import 'package:expense_management/features/settings/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<UserProfile> call({
    required String displayName,
    required String currencyCode,
    required String phoneNumber,
    required String address,
    required String gender,
  }) {
    return repository.updateProfile(
      displayName: displayName,
      currencyCode: currencyCode,
      phoneNumber: phoneNumber,
      address: address,
      gender: gender,
    );
  }
}
