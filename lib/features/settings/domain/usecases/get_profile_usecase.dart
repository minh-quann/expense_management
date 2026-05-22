import 'package:expense_management/features/settings/domain/entities/user_profile.dart';
import 'package:expense_management/features/settings/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<UserProfile> call() {
    return repository.getProfile();
  }
}
