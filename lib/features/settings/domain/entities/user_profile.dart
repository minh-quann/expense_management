import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final String currencyCode;
  final String phoneNumber;
  final String address;
  final String gender;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.currencyCode,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      currencyCode: json['currency_code'] ?? 'VND',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? currencyCode,
    String? phoneNumber,
    String? address,
    String? gender,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      currencyCode: currencyCode ?? this.currencyCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        currencyCode,
        phoneNumber,
        address,
        gender,
        createdAt,
      ];
}
