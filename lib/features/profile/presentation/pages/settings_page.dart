import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_mode_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _SectionLabel(label: 'Appearance'),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                _ThemeTile(
                  title: 'System default',
                  subtitle: 'Follow your device appearance',
                  icon: Icons.brightness_auto_rounded,
                  mode: ThemeMode.system,
                  selected: themeMode,
                ),
                const Divider(height: 1),
                _ThemeTile(
                  title: 'Light',
                  subtitle: 'Bright and clean',
                  icon: Icons.light_mode_rounded,
                  mode: ThemeMode.light,
                  selected: themeMode,
                ),
                const Divider(height: 1),
                _ThemeTile(
                  title: 'Dark',
                  subtitle: 'Easier on the eyes at night',
                  icon: Icons.dark_mode_rounded,
                  mode: ThemeMode.dark,
                  selected: themeMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _SectionLabel(label: 'About'),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.storefront_outlined, color: scheme.primary),
                  title: const Text('Eight Shop'),
                  subtitle: const Text('A modern shopping experience'),
                  trailing: Text(
                    'v${AppConstants.appVersion}',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.storage_outlined),
                  title: Text('Local-first data'),
                  subtitle: Text(
                    'Your cart, favorites, orders and profile are stored on this device.',
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.cloud_outlined),
                  title: Text('Product catalogue'),
                  subtitle: Text(
                    'Products and categories are loaded from the Eight Shop API.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              'Made with Flutter, Riverpod and BLoC',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.mode,
    required this.selected,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ThemeMode mode;
  final ThemeMode selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = mode == selected;

    return ListTile(
      onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(mode),
      leading: Icon(icon, color: isSelected ? scheme.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        isSelected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_off_rounded,
        color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
      ),
    );
  }
}
