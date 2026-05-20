import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfileEvent extends ProfileEvent {}

class UpdateProfileDetailsEvent extends ProfileEvent {
  final String displayName;
  final String currencyCode;
  final String phoneNumber;
  final String address;
  final String gender;

  const UpdateProfileDetailsEvent({
    required this.displayName,
    required this.currencyCode,
    required this.phoneNumber,
    required this.address,
    required this.gender,
  });

  @override
  List<Object?> get props => [displayName, currencyCode, phoneNumber, address, gender];
}

class UploadAvatarEvent extends ProfileEvent {
  final String localFilePath;

  const UploadAvatarEvent({required this.localFilePath});

  @override
  List<Object?> get props => [localFilePath];
}
