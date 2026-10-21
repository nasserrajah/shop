import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.name,
    required super.email,
    required super.avatarUrl,
    super.phone,
    super.address,
    super.isGuest,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: (json['name'] ?? 'Guest Shopper').toString(),
      email: (json['email'] ?? 'guest@eightshop.dev').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      isGuest: json['isGuest'] is bool ? json['isGuest'] as bool : false,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      name: profile.name,
      email: profile.email,
      avatarUrl: profile.avatarUrl,
      phone: profile.phone,
      address: profile.address,
      isGuest: profile.isGuest,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'address': address,
      'isGuest': isGuest,
    };
  }
}
