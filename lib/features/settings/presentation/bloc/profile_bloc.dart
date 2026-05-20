import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_management/core/utils/auth_token_manager.dart';
import 'package:expense_management/features/settings/data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(ProfileInitial()) {
    on<FetchProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await _repository.getProfile();
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
        final profile = await _repository.updateProfile(
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
        final profile = await _repository.uploadAvatar(event.localFilePath);
        // Update local cache
        await AuthTokenManager.savePhotoUrl(profile.photoUrl);
        
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileFailure(e.toString()));
      }
    });
  }
}
