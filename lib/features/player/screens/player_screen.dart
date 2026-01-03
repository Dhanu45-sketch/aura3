// lib/features/player/screens/player_screen.dart
// CAREFULLY UPDATED: Added responsive layout while preserving ALL existing functionality

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math';
import '../../../core/models/sound.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../providers/audio_provider.dart';
import '../../library/providers/favorites_provider.dart';
import '../../profile/providers/preferences_provider.dart';
import '../../library/providers/download_provider.dart';

class PlayerScreen extends StatefulWidget {
  final List<Sound> playlist;
  final int initialIndex;
  final String? playlistId;

  const PlayerScreen({
    super.key,
    required this.playlist,
    this.initialIndex = 0,
    this.playlistId,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  Duration _listenedDuration = Duration.zero;
  bool _hasStartedPlaying = false;
  late int _currentIndex;

  // Shake detection variables (PRESERVED)
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;
  static const double _shakeThreshold = 15.0;
  static const int _shakeCooldown = 1000;
  bool _shakeEnabled = true;
  bool _showShakeIndicator = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.playlist.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPlayback();
      _initializeShakeDetection();
    });
  }

  Sound get _currentSound => widget.playlist[_currentIndex];
  bool get _hasNext => _currentIndex < widget.playlist.length - 1;
  bool get _hasPrevious => _currentIndex > 0;

  Future<void> _startPlayback() async {
    if (_hasStartedPlaying) return;
    _hasStartedPlaying = true;

    final audioProvider = context.read<AudioProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();

    audioProvider.playSound(
      _currentSound,
      playlistId: widget.playlistId,
      playlist: widget.playlist,
    );

    favoritesProvider.addRecentlyPlayed(_currentSound.id);
  }

  void _initializeShakeDetection() {
    _accelerometerSubscription = accelerometerEventStream().listen(
          (AccelerometerEvent event) {
        if (!_shakeEnabled) return;

        final double acceleration = sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z,
        );

        if (acceleration > _shakeThreshold) {
          final now = DateTime.now();

          if (_lastShakeTime == null ||
              now.difference(_lastShakeTime!).inMilliseconds > _shakeCooldown) {
            _lastShakeTime = now;
            _onShakeDetected();
          }
        }
      },
      onError: (error) {
        debugPrint('Accelerometer error: $error');
      },
    );
  }

  void _onShakeDetected() {
    debugPrint('Shake detected! Skipping to next track...');

    setState(() {
      _showShakeIndicator = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showShakeIndicator = false;
        });
      }
    });

    _playNext();
  }

  void _playNext() {
    if (!_hasNext) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('No more tracks in playlist'),
            ],
          ),
          backgroundColor: AppColors.primaryGlass,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex++;
      _listenedDuration = Duration.zero;
    });

    final audioProvider = context.read<AudioProvider>();
    audioProvider.playSound(
      _currentSound,
      playlistId: widget.playlistId,
      playlist: widget.playlist,
    );
  }

  void _playPrevious() {
    if (!_hasPrevious) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Already at first track'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex--;
      _listenedDuration = Duration.zero;
    });

    final audioProvider = context.read<AudioProvider>();
    audioProvider.playSound(
      _currentSound,
      playlistId: widget.playlistId,
      playlist: widget.playlist,
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();

    if (_listenedDuration.inSeconds > 10) {
      context.read<PreferencesProvider>().addListeningSession(
        _currentSound.id,
        _listenedDuration.inSeconds,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final elementColor = AppColors.getElementColor(_currentSound.element);
    final elementSolidColor = AppColors.getElementSolidColor(_currentSound.element);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.expand_more_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, _) {
              final isFavorite = favoritesProvider.isFavorite(_currentSound.id);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : AppColors.textPrimary,
                ),
                onPressed: () {
                  favoritesProvider.toggleFavorite(_currentSound.id);
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              _shakeEnabled ? Icons.vibration : Icons.phone_android,
              color: _shakeEnabled ? AppColors.primaryGlass : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _shakeEnabled = !_shakeEnabled;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _shakeEnabled
                        ? 'Shake to skip: ON'
                        : 'Shake to skip: OFF',
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              elementColor.withOpacity(0.3),
              elementColor.withOpacity(0.2),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Consumer<AudioProvider>(
                builder: (context, audioProvider, _) {
                  if (audioProvider.errorMessage != null) {
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
                            audioProvider.errorMessage!,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      isLandscape
                          ? _buildLandscapeLayout(audioProvider, elementSolidColor)
                          : _buildPortraitLayout(audioProvider, elementSolidColor),

                      if (audioProvider.isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: GlassContainer(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      elementSolidColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading ${_currentSound.title}...',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              if (_showShakeIndicator)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.skip_next_rounded,
                                size: 64,
                                color: AppColors.getElementSolidColor(_currentSound.element),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Skipping to next track...',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ).animate().scale(
                          duration: 400.ms,
                          curve: Curves.elasticOut,
                        ).fadeIn(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(AudioProvider audioProvider, Color elementSolidColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildArtwork(elementSolidColor),
          const SizedBox(height: 40),
          _buildSoundInfo(elementSolidColor),
          const SizedBox(height: 40),
          _buildProgressBar(audioProvider, elementSolidColor),
          const SizedBox(height: 40),
          _buildControls(audioProvider, elementSolidColor),
          const SizedBox(height: 32),
          _buildVolumeControl(audioProvider),
          const SizedBox(height: 20),
          _buildShakeHint(),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(AudioProvider audioProvider, Color elementSolidColor) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxScrollHeight = screenHeight * 0.7;

    return Row(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildArtwork(elementSolidColor, size: 200),
            ),
          ),
        ),
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxScrollHeight,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSoundInfo(elementSolidColor),
                  const SizedBox(height: 24),
                  _buildProgressBar(audioProvider, elementSolidColor),
                  const SizedBox(height: 24),
                  _buildControls(audioProvider, elementSolidColor),
                  const SizedBox(height: 20),
                  _buildVolumeControl(audioProvider),
                  const SizedBox(height: 16),
                  _buildShakeHint(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArtwork(Color elementSolidColor, {double size = 280}) {
    return Hero(
      tag: 'sound_${_currentSound.id}',
      child: GlassContainer(
        padding: const EdgeInsets.all(0),
        width: size,
        height: size,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                elementSolidColor,
                elementSolidColor.withOpacity(0.6),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              _getElementIcon(_currentSound.element),
              size: size * 0.43,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildSoundInfo(Color elementSolidColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _currentSound.title,
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          _currentSound.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getElementIcon(_currentSound.element),
                    size: 20,
                    color: elementSolidColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentSound.element.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: elementSolidColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildPlaybackSourceIndicator(),
          ],
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildProgressBar(AudioProvider audioProvider, Color elementSolidColor) {
    return StreamBuilder<Duration>(
      stream: audioProvider.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = audioProvider.duration ?? Duration.zero;

        if (position > _listenedDuration) {
          _listenedDuration = position;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: elementSolidColor,
                  inactiveTrackColor: AppColors.borderGlass,
                  thumbColor: Colors.white,
                  overlayColor: elementSolidColor.withOpacity(0.3),
                ),
                child: Slider(
                  value: duration.inMilliseconds > 0
                      ? position.inMilliseconds.toDouble()
                      : 0.0,
                  max: duration.inMilliseconds > 0
                      ? duration.inMilliseconds.toDouble()
                      : 1.0,
                  onChanged: (value) {
                    audioProvider.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _formatDuration(duration),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls(AudioProvider audioProvider, Color elementSolidColor) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.playlistId != null || widget.playlist.length > 1) ...[
            Text(
              widget.playlistId != null
                  ? 'Playing from ${_getPlaylistName(widget.playlistId!)}'
                  : 'Playlist',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track ${_currentIndex + 1} of ${widget.playlist.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: audioProvider.isLooping ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                onPressed: audioProvider.toggleLoop,
                color: audioProvider.isLooping ? AppColors.primaryGlass : AppColors.textSecondary,
              ),
              _buildControlButton(
                icon: Icons.skip_previous_rounded,
                onPressed: _hasPrevious ? _playPrevious : null,
                size: 32,
                color: _hasPrevious ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.3),
              ),
              _buildPlayPauseButton(audioProvider, elementSolidColor),
              _buildControlButton(
                icon: Icons.skip_next_rounded,
                onPressed: _hasNext ? _playNext : null,
                size: 32,
                color: _hasNext ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.3),
              ),
              _buildControlButton(
                icon: Icons.playlist_play_rounded,
                onPressed: () {
                  _showPlaylistDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).scale();
  }

  Widget _buildPlayPauseButton(AudioProvider audioProvider, Color elementSolidColor) {
    return StreamBuilder<bool>(
      stream: audioProvider.playingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;

        return GestureDetector(
          onTap: audioProvider.togglePlayPause,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  elementSolidColor,
                  elementSolidColor.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: elementSolidColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
        ).animate(
          target: isPlaying ? 1 : 0,
        ).scale(
          duration: 200.ms,
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 28,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, size: size),
      color: color ?? AppColors.textPrimary,
      onPressed: onPressed,
    );
  }

  Widget _buildVolumeControl(AudioProvider audioProvider) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.volume_down_rounded,
            color: AppColors.textSecondary,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: AppColors.primaryGlass,
                inactiveTrackColor: AppColors.borderGlass,
                thumbColor: Colors.white,
                overlayColor: AppColors.primaryGlass.withOpacity(0.3),
              ),
              child: Slider(
                value: audioProvider.volume,
                onChanged: audioProvider.setVolume,
              ),
            ),
          ),
          Icon(
            Icons.volume_up_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildShakeHint() {
    if (!_shakeEnabled) return const SizedBox.shrink();

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.vibration,
            size: 18,
            color: AppColors.primaryGlass,
          ),
          const SizedBox(width: 8),
          Text(
            'Shake phone to skip',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).fadeIn(duration: 1500.ms);
  }

  Widget _buildPlaybackSourceIndicator() {
    return FutureBuilder<String?>(
      future: context.read<DownloadProvider>().getLocalFilePath(_currentSound),
      builder: (context, snapshot) {
        final isLocal = snapshot.data != null;

        return GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLocal ? Icons.phone_android_rounded : Icons.cloud_rounded,
                size: 16,
                color: isLocal ? Colors.green : AppColors.primaryGlass,
              ),
              const SizedBox(width: 8),
              Text(
                isLocal ? 'Playing Offline' : 'Streaming',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isLocal ? Colors.green : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPlaylistDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        margin: const EdgeInsets.all(16),
        child: GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.playlist_play_rounded, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Now Playing',
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
              if (widget.playlistId != null)
                Text(
                  _getPlaylistName(widget.playlistId!),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.playlist.length,
                  itemBuilder: (context, index) {
                    final sound = widget.playlist[index];
                    final isCurrent = index == _currentIndex;

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _currentIndex = index;
                          _listenedDuration = Duration.zero;
                        });
                        final audioProvider = context.read<AudioProvider>();
                        audioProvider.playSound(
                          sound,
                          playlistId: widget.playlistId,
                          playlist: widget.playlist,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primaryGlass.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: isCurrent
                              ? Border.all(color: AppColors.primaryGlass, width: 2)
                              : null,
                        ),
                        child: Row(
                          children: [
                            if (isCurrent)
                              Icon(
                                Icons.graphic_eq_rounded,
                                color: AppColors.primaryGlass,
                                size: 20,
                              )
                            else
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sound.title,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: isCurrent ? AppColors.primaryGlass : AppColors.textPrimary,
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    sound.formattedDuration,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              Icon(
                                Icons.play_arrow_rounded,
                                color: AppColors.primaryGlass,
                              ),
                          ],
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

  String _getPlaylistName(String playlistId) {
    switch (playlistId) {
      case 'earth':
        return 'Earth Sounds';
      case 'fire':
        return 'Fire Sounds';
      case 'water':
        return 'Water Sounds';
      case 'wind':
        return 'Wind Sounds';
      case 'favorites':
        return 'Favorites';
      case 'downloads':
        return 'Downloads';
      case 'recently_played':
        return 'Recently Played';
      default:
        return 'Playlist';
    }
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}