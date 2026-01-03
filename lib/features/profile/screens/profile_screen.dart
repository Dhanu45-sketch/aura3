import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/preferences_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final prefsProvider = context.watch<PreferencesProvider>();
    final user = authProvider.user;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.accentGlass.withOpacity(0.1),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: const Text('Profile'),
              ),
              // RESPONSIVE: Different layouts for landscape/portrait
              if (isLandscape)
                _buildLandscapeLayout(context, user, prefsProvider, authProvider)
              else
                _buildPortraitLayout(context, user, prefsProvider, authProvider),
            ],
          ),
        ),
      ),
    );
  }

  // PORTRAIT: Single column (original layout)
  Widget _buildPortraitLayout(
      BuildContext context,
      dynamic user,
      PreferencesProvider prefsProvider,
      AuthProvider authProvider,
      ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildProfileHeader(context, user?.displayName, user?.email, prefsProvider),
          const SizedBox(height: 24),
          _buildStatsGrid(context, prefsProvider),
          const SizedBox(height: 24),
          _buildSettingsSection(context, prefsProvider),
          const SizedBox(height: 24),
          _buildAccountSection(context, authProvider),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  // LANDSCAPE: Two-column layout for better space usage
  Widget _buildLandscapeLayout(
      BuildContext context,
      dynamic user,
      PreferencesProvider prefsProvider,
      AuthProvider authProvider,
      ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxScrollHeight = screenHeight * 0.7; // 70% of screen height

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN: Profile & Stats
              Expanded(
                child: Column(
                  children: [
                    _buildProfileHeader(context, user?.displayName, user?.email, prefsProvider),
                    const SizedBox(height: 16),
                    _buildStatsGrid(context, prefsProvider),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // RIGHT COLUMN: Settings & Account (Scrollable)
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: maxScrollHeight,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSettingsSection(context, prefsProvider),
                        const SizedBox(height: 24),
                        _buildAccountSection(context, authProvider),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context,
      String? name,
      String? email,
      PreferencesProvider prefsProvider,
      ) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile picture
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: prefsProvider.profilePictureUrl == null
                      ? LinearGradient(
                    colors: [
                      AppColors.primaryGlass,
                      AppColors.accentGlass,
                    ],
                  )
                      : null,
                  image: prefsProvider.profilePictureUrl != null
                      ? DecorationImage(
                    image: NetworkImage(prefsProvider.profilePictureUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: prefsProvider.isUploadingImage
                    ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : prefsProvider.profilePictureUrl == null
                    ? Center(
                  child: Text(
                    name?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name and email
          Text(
            name ?? 'User Name',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            email ?? 'user@email.com',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Edit button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGlass,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatsGrid(BuildContext context, PreferencesProvider prefsProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.timer_rounded,
            value: prefsProvider.formattedListeningTime,
            label: 'Total Time',
            color: AppColors.earthGlass,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_fire_department_rounded,
            value: '${prefsProvider.streak}',
            label: 'Day Streak',
            color: AppColors.fireGlass,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildStatCard(
      BuildContext context, {
        required IconData icon,
        required String value,
        required String label,
        required Color color,
      }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      color: color.withOpacity(0.1),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, PreferencesProvider prefsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 16),
        _buildThemeSelector(context, prefsProvider),
        // REMOVED: Auto Play toggle (not functional)
        // REMOVED: Notifications toggle (not functional)
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms);
  }

  Widget _buildThemeSelector(BuildContext context, PreferencesProvider prefsProvider) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_rounded,
                color: AppColors.primaryGlass,
              ),
              const SizedBox(width: 16),
              Text(
                'Theme',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  context,
                  'Light',
                  Icons.light_mode_rounded,
                  'light',
                  prefsProvider.themeMode == 'light',
                      () => prefsProvider.setThemeMode('light'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThemeOption(
                  context,
                  'Dark',
                  Icons.dark_mode_rounded,
                  'dark',
                  prefsProvider.themeMode == 'dark',
                      () => prefsProvider.setThemeMode('dark'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThemeOption(
                  context,
                  'System',
                  Icons.settings_suggest_rounded,
                  'system',
                  prefsProvider.themeMode == 'system',
                      () => prefsProvider.setThemeMode('system'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
      BuildContext context,
      String label,
      IconData icon,
      String value,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGlass.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGlass : AppColors.borderGlass,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryGlass : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Account',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 16),
        // REMOVED: Help & Support (not functional)
        _buildSettingItem(
          context,
          Icons.info_rounded,
          'About',
              () {
            _showAboutDialog(context);
          },
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          context,
          Icons.logout_rounded,
          'Logout',
              () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => _buildLogoutDialog(context),
            );

            if (confirmed == true) {
              authProvider.signOut();
            }
          },
          color: Colors.red,
        ),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
  }

  Widget _buildSettingItem(
      BuildContext context,
      IconData icon,
      String label,
      VoidCallback onTap, {
        Color? color,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? AppColors.primaryGlass,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Logout', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text(
        'Are you sure you want to logout?',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Logout'),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('About Aura 3', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 3.0.0',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'A liquid glass themed ASMR and meditation app designed to help you relax, focus, and find inner peace.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2025 Aura 3',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}