// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/preferences_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final prefsProvider = context.watch<PreferencesProvider>();
    final user = authProvider.user;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.accentGlass.withValues(alpha: 0.1),
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
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildProfileHeader(context, user?.displayName, user?.email),
                    const SizedBox(height: 24),
                    _buildStatsGrid(context, prefsProvider),
                    const SizedBox(height: 24),
                    _buildPreferencesSection(context, prefsProvider),
                    const SizedBox(height: 24),
                    _buildSettingsSection(context, authProvider),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String? name, String? email) {
    final prefsProvider = context.watch<PreferencesProvider>();
    final authProvider = context.read<AuthProvider>();

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => _showImagePickerOptions(context, authProvider.user?.uid ?? ''),
                child: Container(
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
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showImagePickerOptions(context, authProvider.user?.uid ?? ''),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGlass,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.backgroundDark,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name ?? 'User Name',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            email ?? 'user@email.com',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, String userId) {
    final prefsProvider = context.read<PreferencesProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Profile Picture',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryGlass),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final success = await prefsProvider.updateProfilePictureFromCamera(userId);
                  if (context.mounted) {
                    _showMessage(
                      context,
                      success ? 'Profile picture updated!' : 'Failed to update picture',
                      success,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primaryGlass),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final success = await prefsProvider.updateProfilePictureFromGallery(userId);
                  if (context.mounted) {
                    _showMessage(
                      context,
                      success ? 'Profile picture updated!' : 'Failed to update picture',
                      success,
                    );
                  }
                },
              ),
              if (prefsProvider.profilePictureUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.red),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    final success = await prefsProvider.removeProfilePicture();
                    if (context.mounted) {
                      _showMessage(
                        context,
                        success ? 'Profile picture removed' : 'Failed to remove picture',
                        success,
                      );
                    }
                  },
                ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, PreferencesProvider prefsProvider) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, prefsProvider.formattedListeningTime, 'Total Time')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, '45', 'Sessions')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, '${prefsProvider.streak}', 'Streak')),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context, PreferencesProvider prefsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Preferences',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 16),
        _buildThemeSelector(context, prefsProvider),
        const SizedBox(height: 12),
        _buildToggleSetting(
          context,
          icon: Icons.play_circle_outline_rounded,
          title: 'Auto Play',
          subtitle: 'Continue playing similar sounds',
          value: prefsProvider.autoPlay,
          onChanged: (value) => prefsProvider.setAutoPlay(value),
        ),
        const SizedBox(height: 12),
        _buildToggleSetting(
          context,
          icon: Icons.notifications_rounded,
          title: 'Notifications',
          subtitle: 'Daily meditation reminders',
          value: prefsProvider.notificationsEnabled,
          onChanged: (value) => prefsProvider.setNotificationsEnabled(value),
        ),
        const SizedBox(height: 12),
        _buildQualitySelector(context, prefsProvider),
      ],
    );
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
              ? AppColors.primaryGlass.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGlass
                : AppColors.borderGlass,
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

  Widget _buildToggleSetting(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required bool value,
        required Function(bool) onChanged,
      }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGlass),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGlass,
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySelector(BuildContext context, PreferencesProvider prefsProvider) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.high_quality_rounded,
                color: AppColors.primaryGlass,
              ),
              const SizedBox(width: 16),
              Text(
                'Download Quality',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQualityChip(
                  context,
                  'Low',
                  'low',
                  prefsProvider.downloadQuality == 'low',
                      () => prefsProvider.setDownloadQuality('low'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQualityChip(
                  context,
                  'Medium',
                  'medium',
                  prefsProvider.downloadQuality == 'medium',
                      () => prefsProvider.setDownloadQuality('medium'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQualityChip(
                  context,
                  'High',
                  'high',
                  prefsProvider.downloadQuality == 'high',
                      () => prefsProvider.setDownloadQuality('high'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityChip(
      BuildContext context,
      String label,
      String value,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGlass.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryGlass : AppColors.borderGlass,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, AuthProvider authProvider) {
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
        _buildSettingItem(context, Icons.download_rounded, 'Downloads', () {}),
        const SizedBox(height: 12),
        _buildSettingItem(context, Icons.help_rounded, 'Help & Support', () {}),
        const SizedBox(height: 12),
        _buildSettingItem(context, Icons.info_rounded, 'About', () {}),
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
    );
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
}
