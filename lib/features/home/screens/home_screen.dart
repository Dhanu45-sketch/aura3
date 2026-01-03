import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/sound.dart';
import '../../player/screens/player_screen.dart';
import '../../sounds/providers/sound_provider.dart';
import '../../library/providers/favorites_provider.dart';
import '../../../core/services/connectivity_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _expandedElement;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _listenToConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await connectivityService.checkConnectivity();
    if (mounted) {
      setState(() => _isOnline = isOnline);
    }
  }

  void _listenToConnectivity() {
    connectivityService.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() => _isOnline = isOnline);
      }
    });
  }

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
            return CustomScrollView(
              slivers: [
                _buildAppBar(context),

                // Network Status Banner
                if (!_isOnline)
                  SliverToBoxAdapter(
                    child: _buildOfflineBanner(),
                  ),

                // Welcome Section
                SliverToBoxAdapter(
                  child: _buildWelcomeSection(context),
                ),

                // Loading State
                if (soundProvider.isLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGlass,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading sounds...',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Error State
                if (soundProvider.errorMessage != null && !soundProvider.isLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              soundProvider.errorMessage!,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => soundProvider.fetchSounds(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Elements Grid/List - RESPONSIVE
                if (!soundProvider.isLoading && soundProvider.errorMessage == null)
                  _buildResponsiveElementCards(context, soundProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  // RESPONSIVE: Build grid for landscape, list for portrait
  Widget _buildResponsiveElementCards(BuildContext context, SoundProvider soundProvider) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      // LANDSCAPE: 2-column grid
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5, // Wider cards in landscape
          ),
          delegate: SliverChildListDelegate([
            _buildElementCard(
              context,
              'Earth',
              'earth',
              AppColors.earthGlass,
              AppColors.earthSolid,
              soundProvider.getSoundsByElement('earth'),
            ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2),

            _buildElementCard(
              context,
              'Fire',
              'fire',
              AppColors.fireGlass,
              AppColors.fireSolid,
              soundProvider.getSoundsByElement('fire'),
            ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.2),

            _buildElementCard(
              context,
              'Water',
              'water',
              AppColors.waterGlass,
              AppColors.waterSolid,
              soundProvider.getSoundsByElement('water'),
            ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.2),

            _buildElementCard(
              context,
              'Wind',
              'wind',
              AppColors.windGlass,
              AppColors.windSolid,
              soundProvider.getSoundsByElement('wind'),
            ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.2),
          ]),
        ),
      );
    } else {
      // PORTRAIT: Single column list (current layout)
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            _buildElementCard(
              context,
              'Earth',
              'earth',
              AppColors.earthGlass,
              AppColors.earthSolid,
              soundProvider.getSoundsByElement('earth'),
            ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2),

            const SizedBox(height: 16),

            _buildElementCard(
              context,
              'Fire',
              'fire',
              AppColors.fireGlass,
              AppColors.fireSolid,
              soundProvider.getSoundsByElement('fire'),
            ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.2),

            const SizedBox(height: 16),

            _buildElementCard(
              context,
              'Water',
              'water',
              AppColors.waterGlass,
              AppColors.waterSolid,
              soundProvider.getSoundsByElement('water'),
            ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.2),

            const SizedBox(height: 16),

            _buildElementCard(
              context,
              'Wind',
              'wind',
              AppColors.windGlass,
              AppColors.windSolid,
              soundProvider.getSoundsByElement('wind'),
            ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.2),
          ]),
        ),
      );
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGlass,
                  AppColors.secondaryGlass,
                ],
              ),
            ),
            child: const Icon(Icons.waves_rounded, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('Aura'),
        ],
      ),
      actions: [
        Consumer<SoundProvider>(
          builder: (context, soundProvider, _) {
            return IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: soundProvider.isLoading
                  ? null
                  : () => soundProvider.fetchSounds(),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.orange.shade300, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Offline Mode - Using cached data',
              style: TextStyle(
                color: Colors.orange.shade200,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.5);
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Text(
            'Choose your element to begin',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildElementCard(
      BuildContext context,
      String elementName,
      String elementKey,
      Color glassColor,
      Color solidColor,
      List<Sound> sounds,
      ) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isExpanded = _expandedElement == elementKey;

    // FIXED: Calculate max height for expanded content
    final screenHeight = MediaQuery.of(context).size.height;
    final maxExpandedHeight = isLandscape
        ? screenHeight * 0.4  // 40% of screen in landscape
        : screenHeight * 0.5; // 50% of screen in portrait

    return GestureDetector(
      onTap: () {
        // CHANGED: Primary tap now plays the entire element playlist
        if (sounds.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlayerScreen(
                playlist: sounds,
                initialIndex: 0,
                playlistId: elementKey,
              ),
            ),
          );
        }
      },
      child: GlassContainer(
        padding: EdgeInsets.zero,
        color: glassColor.withAlpha(isExpanded ? 51 : 26),
        border: Border.all(
          color: isExpanded ? solidColor.withAlpha(128) : glassColor.withAlpha(77),
          width: isExpanded ? 2 : 1.5,
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Element Icon - PRESERVED CUSTOM ICONS
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          solidColor,
                          solidColor.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: isExpanded ? [
                        BoxShadow(
                          color: solidColor.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ] : [],
                    ),
                    child: Image.asset(
                      'assets/images/element_${elementKey.toLowerCase()}.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image not found
                        return Icon(
                          _getElementIcon(elementKey),
                          size: 32,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Element Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          elementName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: solidColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${sounds.length} ${sounds.length == 1 ? 'sound' : 'sounds'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CHANGED: Expand/Collapse icon button
                  IconButton(
                    icon: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: solidColor,
                        size: 32,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _expandedElement = isExpanded ? null : elementKey;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Expanded Content - SCROLLABLE Individual Sound Tiles
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Column(
                children: [
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.white12,
                  ),
                  // FIXED: Wrap in ConstrainedBox + SingleChildScrollView
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxExpandedHeight,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: sounds.asMap().entries.map((entry) {
                          final index = entry.key;
                          final sound = entry.value;
                          return _buildSoundTile(
                            context,
                            sound,
                            solidColor,
                            sounds,
                            index,
                            elementKey,
                            isLast: index == sounds.length - 1,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundTile(
      BuildContext context,
      Sound sound,
      Color elementColor,
      List<Sound> playlist,  // ADDED: Full playlist
      int soundIndex,         // ADDED: Index in playlist
      String playlistId,      // ADDED: Playlist ID
          {bool isLast = false}
      ) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        final isFavorite = favoritesProvider.isFavorite(sound.id);

        return InkWell(
          onTap: () {
            // CHANGED: Pass full playlist with correct index and ID
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlayerScreen(
                  playlist: playlist,
                  initialIndex: soundIndex,
                  playlistId: playlistId,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: isLast ? null : const Border(
                bottom: BorderSide(
                  color: Colors.white12,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Play Button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: elementColor.withOpacity(0.2),
                    border: Border.all(
                      color: elementColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: elementColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Sound Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sound.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sound.formattedDuration,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          if (sound.fileSize != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.storage_rounded,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              sound.fileSize!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (sound.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: sound.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: elementColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: elementColor.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: elementColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                // Favorite Button
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : AppColors.textSecondary,
                    size: 22,
                  ),
                  onPressed: () {
                    favoritesProvider.toggleFavorite(sound.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
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