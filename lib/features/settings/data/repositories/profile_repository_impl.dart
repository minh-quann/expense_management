import 'package:expense_management/features/settings/data/datasources/profile_remote_datasource.dart';
import 'package:expense_management/features/settings/domain/entities/user_profile.dart';
import 'package:expense_management/features/settings/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  // Accept optional parameter for backwards compatibility
  ProfileRepositoryImpl([dynamic _]) : _remoteDataSource = ProfileRemoteDataSourceImpl();

  ProfileRepositoryImpl.withDataSource(this._remoteDataSource);

  @override
  Future<UserProfile> getProfile() {
    return _remoteDataSource.getProfile();
  }

  @override
  Future<UserProfile> updateProfile({
    required String displayName,
    required String currencyCode,
    required String phoneNumber,
    required String address,
    required String gender,
  }) {
    return _remoteDataSource.updateProfile(
      displayName: displayName,
      currencyCode: currencyCode,
      phoneNumber: phoneNumber,
      address: address,
      gender: gender,
    );
  }

  @override
  Future<UserProfile> uploadAvatar(String localFilePath) {
    return _remoteDataSource.uploadAvatar(localFilePath);
  }
}
