import 'package:expense_management/features/settings/domain/entities/user_profile.dart';
import 'package:expense_management/features/settings/domain/repositories/profile_repository.dart';

class UploadAvatarUseCase {
  final ProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  Future<UserProfile> call(String localFilePath) {
    return repository.uploadAvatar(localFilePath);
  }
}
