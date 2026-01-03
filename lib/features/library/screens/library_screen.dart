import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/sound.dart';
import '../../player/screens/player_screen.dart';
import '../../sounds/providers/sound_provider.dart';
import '../providers/favorites_provider.dart';
import '../../library/providers/download_provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 6 tabs: All, Earth, Fire, Water, Wind, Downloads
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
              AppColors.waterGlass.withOpacity(0.1),
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      soundProvider.errorMessage!,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    backgroundColor: AppColors.backgroundDark.withOpacity(0.95),
                    expandedHeight: 60,
                    collapsedHeight: 60,
                    toolbarHeight: 60,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: const EdgeInsets.only(left: 16, bottom: 8),
                      title: Text(
                        'Library',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.favorite_rounded),
                        onPressed: () {
                          _showFavorites(context);
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Search bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildSearchBar(),
                        ),
                        const SizedBox(height: 12),
                        // Tabs
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorColor: AppColors.primaryGlass,
                          labelColor: AppColors.primaryGlass,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                          tabs: [
                            Tab(
                              child: Row(
                                children: [
                                  const Icon(Icons.library_music_rounded, size: 18),
                                  const SizedBox(width: 6),
                                  Text('All (${soundProvider.sounds.length})'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                children: [
                                  const Icon(Icons.forest_rounded, size: 18),
                                  const SizedBox(width: 6),
                                  Text('Earth (${soundProvider.getSoundsByElement('earth').length})'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                children: [
                                  const Icon(Icons.local_fire_department_rounded, size: 18),
                                  const SizedBox(width: 6),
                                  Text('Fire (${soundProvider.getSoundsByElement('fire').length})'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                children: [
                                  const Icon(Icons.water_drop_rounded, size: 18),
                                  const SizedBox(width: 6),
                                  Text('Water (${soundProvider.getSoundsByElement('water').length})'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                children: [
                                  const Icon(Icons.air_rounded, size: 18),
                                  const SizedBox(width: 6),
                                  Text('Wind (${soundProvider.getSoundsByElement('wind').length})'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                children: [
                                  const Icon(Icons.download_rounded, size: 18),
                                  const SizedBox(width: 6),
                                  Consumer<DownloadProvider>(
                                    builder: (context, downloadProvider, _) {
                                      return Text('Downloads (${downloadProvider.downloadedSoundIds.length})');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildSoundsList(context, soundProvider.sounds, soundProvider),
                  _buildSoundsList(
                    context,
                    soundProvider.getSoundsByElement('earth'),
                    soundProvider,
                  ),
                  _buildSoundsList(
                    context,
                    soundProvider.getSoundsByElement('fire'),
                    soundProvider,
                  ),
                  _buildSoundsList(
                    context,
                    soundProvider.getSoundsByElement('water'),
                    soundProvider,
                  ),
                  _buildSoundsList(
                    context,
                    soundProvider.getSoundsByElement('wind'),
                    soundProvider,
                  ),
                  Consumer<DownloadProvider>(
                    builder: (context, downloadProvider, _) {
                      final downloadedSounds = soundProvider.sounds
                          .where((sound) => downloadProvider.isDownloaded(sound.id))
                          .toList();

                      return _buildSoundsList(context, downloadedSounds, soundProvider);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search sounds...',
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          icon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
            },
          )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildSoundsList(
      BuildContext context,
      List<Sound> sounds,
      SoundProvider soundProvider,
      ) {
    final filteredSounds = _searchQuery.isEmpty
        ? sounds
        : sounds.where((sound) {
      return sound.title.toLowerCase().contains(_searchQuery) ||
          sound.description.toLowerCase().contains(_searchQuery) ||
          sound.element.toLowerCase().contains(_searchQuery) ||
          sound.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
    }).toList();

    if (filteredSounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No sounds available'
                  : 'No sounds found for "$_searchQuery"',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // NEW: Check orientation
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      // NEW: LANDSCAPE - 2-column grid
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5, // Wide cards in landscape
        ),
        itemCount: filteredSounds.length,
        itemBuilder: (context, index) {
          return _buildSoundCard(context, filteredSounds[index], index, filteredSounds);
        },
      );
    } else {
      // ORIGINAL: PORTRAIT - Single column list
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredSounds.length,
        itemBuilder: (context, index) {
          final sound = filteredSounds[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSoundCard(context, sound, index, filteredSounds),
          );
        },
      );
    }
  }

  Widget _buildSoundCard(BuildContext context, Sound sound, int index, List<Sound> filteredSounds) {
    return GestureDetector(
      onTap: () {
        final soundProvider = context.read<SoundProvider>();

        String? playlistId;
        List<Sound> fullPlaylist;

        // Determine which playlist we're in based on current tab
        switch (_tabController.index) {
          case 0: // All
            fullPlaylist = soundProvider.sounds;
            playlistId = null;
            break;
          case 1: // Earth
            fullPlaylist = soundProvider.getSoundsByElement('earth');
            playlistId = 'earth';
            break;
          case 2: // Fire
            fullPlaylist = soundProvider.getSoundsByElement('fire');
            playlistId = 'fire';
            break;
          case 3: // Water
            fullPlaylist = soundProvider.getSoundsByElement('water');
            playlistId = 'water';
            break;
          case 4: // Wind
            fullPlaylist = soundProvider.getSoundsByElement('wind');
            playlistId = 'wind';
            break;
          case 5: // Downloads
            final downloadProvider = context.read<DownloadProvider>();
            fullPlaylist = soundProvider.sounds
                .where((s) => downloadProvider.isDownloaded(s.id))
                .toList();
            playlistId = 'downloads';
            break;
          default:
            fullPlaylist = [sound];
            playlistId = null;
        }

        // IMPORTANT: If searching, use filtered list as playlist
        final actualPlaylist = _searchQuery.isNotEmpty ? filteredSounds : fullPlaylist;

        // Find the index in the actual playlist
        final initialIndex = actualPlaylist.indexWhere((s) => s.id == sound.id);

        // Navigate to player with full context
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlayerScreen(
              playlist: actualPlaylist,
              initialIndex: initialIndex != -1 ? initialIndex : 0,
              playlistId: playlistId,
            ),
          ),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Album art / Icon
            Hero(
              tag: 'sound_${sound.id}',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.getElementSolidColor(sound.element),
                      AppColors.getElementSolidColor(sound.element).withOpacity(0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getElementIcon(sound.element),
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Sound info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sound.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sound.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      // Element badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.getElementColor(sound.element).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getElementIcon(sound.element),
                              size: 10,
                              color: AppColors.getElementSolidColor(sound.element),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              sound.element.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getElementSolidColor(sound.element),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Duration badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_rounded,
                              size: 10,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              sound.formattedDuration,
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Downloaded badge (icon only)
                      Consumer<DownloadProvider>(
                        builder: (context, downloadProvider, _) {
                          final isDownloaded = downloadProvider.isDownloaded(sound.id);

                          if (!isDownloaded) return const SizedBox.shrink();

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.offline_pin_rounded,
                              size: 12,
                              color: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action buttons column
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Favorite button
                Consumer<FavoritesProvider>(
                  builder: (context, favoritesProvider, _) {
                    final isFavorite = favoritesProvider.isFavorite(sound.id);
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : AppColors.textSecondary,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        favoritesProvider.toggleFavorite(sound.id);
                      },
                    );
                  },
                ),
                // Download button
                Consumer<DownloadProvider>(
                  builder: (context, downloadProvider, _) {
                    final isDownloaded = downloadProvider.isDownloaded(sound.id);
                    final isDownloading = downloadProvider.isDownloadingSound(sound.id);
                    final progress = downloadProvider.getProgress(sound.id);

                    if (isDownloading) {
                      return SizedBox(
                        width: 32,
                        height: 32,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryGlass,
                                ),
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return IconButton(
                      icon: Icon(
                        isDownloaded ? Icons.download_done_rounded : Icons.download_rounded,
                        color: isDownloaded ? Colors.green : AppColors.textSecondary,
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () async {
                        if (isDownloaded) {
                          // Show dialog to delete
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.backgroundDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text('Delete Download?'),
                              content: Text('Remove ${sound.title} from downloads?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            final success = await downloadProvider.deleteDownload(sound);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success ? 'Download removed' : 'Failed to remove'),
                                  backgroundColor: success ? Colors.orange : Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          }
                        } else {
                          // Download
                          final success = await downloadProvider.downloadSound(sound);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success ? '${sound.title} downloaded!' : 'Download failed',
                                ),
                                backgroundColor: success ? Colors.green : Colors.red,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
                // Play button
                IconButton(
                  icon: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.getElementSolidColor(sound.element),
                    size: 24,
                  ),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    final soundProvider = context.read<SoundProvider>();

                    String? playlistId;
                    List<Sound> fullPlaylist;

                    switch (_tabController.index) {
                      case 0:
                        fullPlaylist = soundProvider.sounds;
                        playlistId = null;
                        break;
                      case 1:
                        fullPlaylist = soundProvider.getSoundsByElement('earth');
                        playlistId = 'earth';
                        break;
                      case 2:
                        fullPlaylist = soundProvider.getSoundsByElement('fire');
                        playlistId = 'fire';
                        break;
                      case 3:
                        fullPlaylist = soundProvider.getSoundsByElement('water');
                        playlistId = 'water';
                        break;
                      case 4:
                        fullPlaylist = soundProvider.getSoundsByElement('wind');
                        playlistId = 'wind';
                        break;
                      case 5:
                        final downloadProvider = context.read<DownloadProvider>();
                        fullPlaylist = soundProvider.sounds
                            .where((s) => downloadProvider.isDownloaded(s.id))
                            .toList();
                        playlistId = 'downloads';
                        break;
                      default:
                        fullPlaylist = [sound];
                        playlistId = null;
                    }

                    final actualPlaylist = _searchQuery.isNotEmpty ? filteredSounds : fullPlaylist;
                    final initialIndex = actualPlaylist.indexWhere((s) => s.id == sound.id);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                          playlist: actualPlaylist,
                          initialIndex: initialIndex != -1 ? initialIndex : 0,
                          playlistId: playlistId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ).animate(delay: (50 * index).ms).fadeIn(duration: 400.ms).slideX(
        begin: 0.1,
        end: 0,
      ),
    );
  }

  void _showFavorites(BuildContext context) {
    final favoritesProvider = context.read<FavoritesProvider>();
    final soundProvider = context.read<SoundProvider>();

    // Get favorite sounds
    final favoriteSounds = soundProvider.sounds
        .where((sound) => favoritesProvider.isFavorite(sound.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        margin: const EdgeInsets.all(16),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Favorites',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (favoriteSounds.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No favorites yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the heart icon on sounds to add them here',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: favoriteSounds.length,
                    itemBuilder: (context, index) {
                      final sound = favoriteSounds[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PlayerScreen(
                                  playlist: favoriteSounds,
                                  initialIndex: index,
                                  playlistId: 'favorites',
                                ),
                              ),
                            );
                          },
                          child: GlassContainer(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.getElementSolidColor(sound.element),
                                        AppColors.getElementSolidColor(sound.element)
                                            .withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    _getElementIcon(sound.element),
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sound.title,
                                        style: Theme.of(context).textTheme.titleSmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${sound.element} • ${sound.formattedDuration}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.play_arrow_rounded,
                                    color: AppColors.getElementSolidColor(sound.element),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => PlayerScreen(
                                          playlist: favoriteSounds,
                                          initialIndex: index,
                                          playlistId: 'favorites',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
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