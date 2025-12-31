import 'package:aura3/features/sounds/providers/sound_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/sound.dart';
import '../../player/screens/player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.primaryGlass.withAlpha(26),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: Consumer<SoundProvider>(
          builder: (context, soundProvider, _) {
            if (soundProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (soundProvider.errorMessage != null) {
              return Center(child: Text(soundProvider.errorMessage!));
            }

            return CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildWelcomeCard(context),
                      const SizedBox(height: 24),
                      _buildQuickStats(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Elements'),
                      const SizedBox(height: 16),
                      _buildElementsGrid(context, soundProvider),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Recently Played'),
                      const SizedBox(height: 16),
                      _buildRecentlyPlayed(context, soundProvider),
                      const SizedBox(height: 100), // Space for bottom nav
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text('Aura 3'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_rounded),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          AppColors.primaryGlass.withAlpha(77),
          AppColors.secondaryGlass.withAlpha(77),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Evening',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ready to relax?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Continue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGlass,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.timer_rounded,
            value: '2.5h',
            label: 'Today',
            color: AppColors.earthGlass,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_fire_department_rounded,
            value: '7',
            label: 'Streak',
            color: AppColors.fireGlass,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.mood_rounded,
            value: '94%',
            label: 'Mood',
            color: AppColors.waterGlass,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      color: color.withAlpha(26),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  Widget _buildElementsGrid(BuildContext context, SoundProvider soundProvider) {
    final elements = [
      {'name': 'Earth', 'icon': '🌍', 'color': AppColors.earthGlass},
      {'name': 'Fire', 'icon': '🔥', 'color': AppColors.fireGlass},
      {'name': 'Water', 'icon': '💧', 'color': AppColors.waterGlass},
      {'name': 'Wind', 'icon': '💨', 'color': AppColors.windGlass},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: elements.length,
      itemBuilder: (context, index) {
        final element = elements[index];
        final sounds = soundProvider.getSoundsByElement(element['name']! as String);

        return _buildElementCard(
          context,
          name: element['name'] as String,
          icon: element['icon'] as String,
          color: element['color'] as Color,
          soundCount: sounds.length,
        ).animate(delay: (100 * index).ms).fadeIn(duration: 600.ms).scale();
      },
    );
  }

  Widget _buildElementCard(
      BuildContext context, {
        required String name,
        required String icon,
        required Color color,
        required int soundCount,
      }) {
    return GestureDetector(
      onTap: () {
        // Navigate to library filtered by element
      },
      child: GlassContainer(
        color: color.withAlpha(38),
        border: Border.all(
          color: color.withAlpha(77),
          width: 1.5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '$soundCount sounds',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayed(BuildContext context, SoundProvider soundProvider) {
    // This will be replaced with real recently played logic later
    final recentSounds = soundProvider.sounds.take(3).toList();

    return Column(
      children: List.generate(
        recentSounds.length,
            (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRecentItem(context, recentSounds[index], index),
        ),
      ),
    );
  }

  Widget _buildRecentItem(BuildContext context, Sound sound, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlayerScreen(sound: sound),
          ),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.getElementSolidColor(sound.element),
                    AppColors.getElementSolidColor(sound.element).withAlpha(153),
                  ],
                ),
              ),
              child: Icon(
                _getElementIcon(sound.element),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sound.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${sound.element} • ${sound.formattedDuration}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow_rounded),
              color: AppColors.primaryGlass,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(sound: sound),
                  ),
                );
              },
            ),
          ],
        ),
      ).animate(delay: (100 * index).ms).fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0),
    );
  }

  IconData _getElementIcon(String element) {
    switch (element.toLowerCase()) {
      case 'earth':
        return Icons.forest_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'wind':
        return Icons.air_rounded;
      default:
        return Icons.music_note_rounded;
    }
  }
}
