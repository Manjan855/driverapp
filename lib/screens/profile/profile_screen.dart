
import 'package:driver_app_saferide/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);
    final driver = authState.driver;
    final themeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTypography.heading(color: scheme.onSurface),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Driver info card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: Text(
                      driver != null && driver.name.isNotEmpty
                          ? driver.name[0].toUpperCase()
                          : 'D',
                      style: AppTypography.display(
                        color: scheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver?.name ?? 'Driver',
                        style: AppTypography.heading(color: scheme.onSurface),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        driver?.phoneNumber ?? '',
                        style: AppTypography.caption(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          driver?.licenseNumber ?? '',
                          style: AppTypography.mono(
                            color: scheme.secondary,
                            size: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Theme section
          _SectionLabel('Appearance', scheme: scheme),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark mode',
                  scheme: scheme,
                  trailing: Switch(
                    value: isDark,
                    onChanged: (val) {
                      ref
                          .read(themeProvider.notifier)
                          .setTheme(val ? ThemeMode.dark : ThemeMode.light);
                    },
                    activeThumbColor: scheme.primary,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.phone_android_outlined,
                  title: 'Follow system theme',
                  scheme: scheme,
                  isLast: true,
                  trailing: Switch(
                    value: themeMode == ThemeMode.system,
                    onChanged: (val) {
                      ref
                          .read(themeProvider.notifier)
                          .setTheme(val ? ThemeMode.system : ThemeMode.dark);
                    },
                    activeThumbColor: scheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Settings section
          _SectionLabel('Settings', scheme: scheme),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notification preferences',
                  scheme: scheme,
                  showChevron: true,
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change password',
                  scheme: scheme,
                  showChevron: true,
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & support',
                  scheme: scheme,
                  isLast: true,
                  showChevron: true,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: Icon(Icons.logout_rounded, size: 18, color: scheme.error),
              label: Text(
                'Log out',
                style: AppTypography.body(color: scheme.error),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: scheme.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Log out?',
          style: AppTypography.heading(color: scheme.onSurface),
        ),
        content: Text(
          'You\'ll need to sign in again before starting your next trip.',
          style: AppTypography.body(
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.body(
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: Text(
              'Log out',
              style: AppTypography.body(color: scheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final ColorScheme scheme;

  const _SectionLabel(this.text, {required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.caption(
        color: scheme.onSurface.withValues(alpha: 0.5),
        size: 12,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final ColorScheme scheme;
  final Widget? trailing;
  final bool isLast;
  final bool showChevron;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.scheme,
    this.trailing,
    this.isLast = false,
    this.showChevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: scheme.outline.withValues(alpha: 0.1),
                  ),
                ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTypography.body(color: scheme.onSurface),
              ),
            ),
            if (trailing != null) trailing!,
            if (showChevron)
              Icon(
                Icons.chevron_right,
                size: 18,
                color: scheme.onSurface.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}
