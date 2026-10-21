import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.phone = '',
    this.address = '',
    this.isGuest = false,
  });

  final String name;
  final String email;
  final String avatarUrl;
  final String phone;
  final String address;
  final bool isGuest;

  factory UserProfile.demo() {
    return const UserProfile(
      name: 'Mark Adam',
      email: 'Sunny_Koelpin45@hotmail.com',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      phone: '+1 (555) 010-2040',
      address: '325 15th Eighth Avenue, New York',
    );
  }

  factory UserProfile.guest() {
    return const UserProfile(
      name: 'Guest Shopper',
      email: 'guest@eightshop.dev',
      avatarUrl: '',
      isGuest: true,
    );
  }

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? phone,
    String? address,
    bool? isGuest,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  @override
  List<Object?> get props => [
        name,
        email,
        avatarUrl,
        phone,
        address,
        isGuest,
      ];
}
