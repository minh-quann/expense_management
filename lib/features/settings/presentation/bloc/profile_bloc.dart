import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/features/settings/domain/repositories/profile_repository.dart';
import 'package:expense_management/features/settings/domain/usecases/get_profile_usecase.dart';
import 'package:expense_management/features/settings/domain/usecases/update_profile_usecase.dart';
import 'package:expense_management/features/settings/domain/usecases/upload_avatar_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;

  ProfileBloc(
    ProfileRepository repository, {
    GetProfileUseCase? getProfileUseCase,
    UpdateProfileUseCase? updateProfileUseCase,
    UploadAvatarUseCase? uploadAvatarUseCase,
  })  : _getProfileUseCase = getProfileUseCase ?? GetProfileUseCase(repository),
        _updateProfileUseCase = updateProfileUseCase ?? UpdateProfileUseCase(repository),
        _uploadAvatarUseCase = uploadAvatarUseCase ?? UploadAvatarUseCase(repository),
        super(ProfileInitial()) {
    on<FetchProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await _getProfileUseCase();
        // Also update local cache
        await AuthTokenManager.saveName(profile.displayName);
        await AuthTokenManager.savePhotoUrl(profile.photoUrl);
        
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<UpdateProfileDetailsEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await _updateProfileUseCase(
          displayName: event.displayName,
          currencyCode: event.currencyCode,
          phoneNumber: event.phoneNumber,
          address: event.address,
          gender: event.gender,
        );
        // Update local cache
        await AuthTokenManager.saveName(profile.displayName);
        
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });

    on<UploadAvatarEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await _uploadAvatarUseCase(event.localFilePath);
        // Update local cache
        await AuthTokenManager.savePhotoUrl(profile.photoUrl);
        
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });
  }
}
