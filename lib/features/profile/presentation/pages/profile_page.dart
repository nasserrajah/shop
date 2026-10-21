import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/error_message.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../../orders/presentation/bloc/orders_state.dart';
import '../../../shell/presentation/bloc/navigation_bloc.dart';
import '../../../shell/presentation/bloc/navigation_event.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sign out?',
      message:
          'Your saved favorites, cart and orders will stay on this device.',
      confirmLabel: 'Sign out',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final result =
        await ref.read(profileControllerProvider.notifier).signOut();
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) => showAppSnackBar(context, 'You have signed out'),
      onFailure: (failure) =>
          showAppSnackBar(context, failure.message, isError: true),
    );
  }

  Future<void> _shareApp(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(
        text:
            'Discover Eight Shop - great products, fast delivery. https://eightshop.example.com',
      ),
    );
    if (!context.mounted) return;
    showAppSnackBar(context, 'Invite link copied to clipboard');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppErrorView(
            message: readableErrorMessage(
              error,
              fallback: 'Unable to load your profile.',
            ),
            onRetry: () => ref.invalidate(profileControllerProvider),
          ),
          data: (profile) => _ProfileContent(
            profile: profile,
            onSignOut: () => _signOut(context, ref),
            onShare: () => _shareApp(context),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({
    required this.profile,
    required this.onSignOut,
    required this.onShare,
  });

  final UserProfile profile;
  final VoidCallback onSignOut;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteCount = ref.watch(favoriteCountProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Profile',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () => AppRouter.pushSettings(context),
              icon: const Icon(Icons.settings_outlined),
            ),
            IconButton(
              tooltip: 'Edit profile',
              onPressed: () => AppRouter.pushEditProfile(context),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: AppAvatar(
            name: profile.name,
            imageUrl: profile.avatarUrl,
            radius: 48,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            profile.name,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 3),
        Center(
          child: Text(
            profile.email,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
        ),
        if (profile.isGuest) ...[
          const SizedBox(height: 10),
          Center(
            child: FilledButton.tonalIcon(
              onPressed: () => AppRouter.pushEditProfile(context),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text('Complete your profile'),
            ),
          ),
        ],
        const SizedBox(height: 20),
        BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, ordersState) {
            return Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.favorite_border_rounded,
                    value: '$favoriteCount',
                    label: 'Favorites',
                    color: AppColors.danger,
                    onTap: () =>
                        context.read<NavigationBloc>().add(const NavigateTo(1)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.receipt_long_outlined,
                    value: '${ordersState.orders.length}',
                    label: 'Orders',
                    color: AppColors.primary,
                    onTap: () => AppRouter.pushOrders(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.shopping_bag_outlined,
                    value: '$cartCount',
                    label: 'Cart',
                    color: AppColors.success,
                    onTap: () =>
                        context.read<NavigationBloc>().add(const NavigateTo(2)),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        _MenuTile(
          icon: Icons.person_outline_rounded,
          title: 'My profile',
          subtitle: 'Name, email, phone and address',
          onTap: () => AppRouter.pushEditProfile(context),
        ),
        _MenuTile(
          icon: Icons.receipt_long_outlined,
          title: 'My orders',
          subtitle: 'Track, cancel or reorder purchases',
          onTap: () => AppRouter.pushOrders(context),
        ),
        _MenuTile(
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'Appearance and app information',
          onTap: () => AppRouter.pushSettings(context),
        ),
        _MenuTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & support',
          subtitle: 'FAQs and contact details',
          onTap: () => AppRouter.pushHelp(context),
        ),
        _MenuTile(
          icon: Icons.share_outlined,
          title: 'Share app',
          subtitle: 'Invite a friend to Eight Shop',
          onTap: onShare,
        ),
        if (!profile.isGuest)
          _MenuTile(
            icon: Icons.logout_rounded,
            title: 'Sign out',
            subtitle: 'Keep your local data on this device',
            color: AppColors.danger,
            onTap: onSignOut,
          ),
        const SizedBox(height: 22),
        Center(
          child: Text(
            '${AppConstants.appName} v${AppConstants.appVersion}',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: (color ?? scheme.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color ?? scheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: color,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
