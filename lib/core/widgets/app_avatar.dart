import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl = '',
    this.radius = 24,
    this.backgroundColor,
  });

  final String name;
  final String imageUrl;
  final double radius;
  final Color? backgroundColor;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final background = backgroundColor ?? AppColors.primarySoft;

    return CircleAvatar(
      radius: radius,
      backgroundColor: background,
      child: ClipOval(
        child: imageUrl.trim().isEmpty
            ? _initialsAvatar()
            : CachedNetworkImage(
                imageUrl: imageUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                placeholder: (context, url) => _initialsAvatar(),
                errorWidget: (context, url, error) => _initialsAvatar(),
              ),
      ),
    );
  }

  Widget _initialsAvatar() {
    return SizedBox.expand(
      child: ColoredBox(
        color: backgroundColor ?? AppColors.primarySoft,
        child: Center(
          child: Text(
            _initials,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: radius * 0.72,
            ),
          ),
        ),
      ),
    );
  }
}
