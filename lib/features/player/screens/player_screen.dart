import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../../core/models/sound.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../providers/audio_provider.dart';
import '../../library/providers/favorites_provider.dart';
import '../../profile/providers/preferences_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
class PlayerScreen extends StatefulWidget {
  final Sound sound;

  const PlayerScreen({
    super.key,
    required this.sound,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  Duration _listenedDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioProvider = context.read<AudioProvider>();
      final favoritesProvider = context.read<FavoritesProvider>();

      // Play sound
      audioProvider.playSound(widget.sound);

      // Add to recently played
      favoritesProvider.addRecentlyPlayed(widget.sound.id);
    });
  }

  @override
  void dispose() {
    // Track listening session
    if (_listenedDuration.inSeconds > 10) {
      context.read<PreferencesProvider>().addListeningSession(
        widget.sound.id,
        _listenedDuration.inSeconds,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
              final isFavorite = favoritesProvider.isFavorite(widget.sound.id);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : AppColors.textPrimary,
                ),
                onPressed: () {
                  favoritesProvider.toggleFavorite(widget.sound.id);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
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
              AppColors.getElementColor(widget.sound.element).withOpacity(0.3),
              AppColors.getElementColor(widget.sound.element).withOpacity(0.2),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AudioProvider>(
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

              if (audioProvider.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.getElementSolidColor(widget.sound.element),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Loading ${widget.sound.title}...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildArtwork(),
                    const SizedBox(height: 40),
                    _buildSoundInfo(),
                    const SizedBox(height: 40),
                    _buildProgressBar(audioProvider),
                    const SizedBox(height: 40),
                    _buildControls(audioProvider),
                    const SizedBox(height: 32),
                    _buildVolumeControl(audioProvider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork() {
    return Hero(
      tag: 'sound_${widget.sound.id}',
      child: GlassContainer(
        padding: const EdgeInsets.all(0),
        width: 280,
        height: 280,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.getElementSolidColor(widget.sound.element),
                AppColors.getElementSolidColor(widget.sound.element).withOpacity(0.6),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              _getElementIcon(widget.sound.element),
              size: 120,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.easeOut);
  }

  Widget _buildSoundInfo() {
    return Column(
      children: [
        Text(
          widget.sound.title,
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          widget.sound.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 16),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getElementIcon(widget.sound.element),
                size: 20,
                color: AppColors.getElementSolidColor(widget.sound.element),
              ),
              const SizedBox(width: 8),
              Text(
                widget.sound.element.toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.getElementSolidColor(widget.sound.element),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildProgressBar(AudioProvider audioProvider) {
    return StreamBuilder<Duration>(
      stream: audioProvider.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = audioProvider.duration ?? Duration.zero;

        // Update listened duration
        if (position > _listenedDuration) {
          _listenedDuration = position;
        }

        return Column(
          children: [
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: AppColors.getElementSolidColor(widget.sound.element),
                  inactiveTrackColor: AppColors.borderGlass,
                  thumbColor: Colors.white,
                  overlayColor: AppColors.getElementSolidColor(widget.sound.element).withOpacity(0.3),
                ),
                child: Slider(
                  value: duration.inMilliseconds > 0
                      ? position.inMilliseconds.toDouble()
                      : 0.0,
                  max: duration.inMilliseconds.toDouble(),
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

  Widget _buildControls(AudioProvider audioProvider) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: audioProvider.isLooping ? Icons.repeat_one_rounded : Icons.repeat_rounded,
            onPressed: audioProvider.toggleLoop,
            color: audioProvider.isLooping ? AppColors.primaryGlass : AppColors.textSecondary,
          ),
          _buildControlButton(
            icon: Icons.replay_10_rounded,
            onPressed: audioProvider.skipBackward,
            size: 32,
          ),
          _buildPlayPauseButton(audioProvider),
          _buildControlButton(
            icon: Icons.forward_10_rounded,
            onPressed: audioProvider.skipForward,
            size: 32,
          ),
          _buildControlButton(
            icon: Icons.playlist_play_rounded,
            onPressed: () {
              // TODO: Show playlist
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).scale();
  }

  Widget _buildPlayPauseButton(AudioProvider audioProvider) {
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
                  AppColors.getElementSolidColor(widget.sound.element),
                  AppColors.getElementSolidColor(widget.sound.element).withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getElementSolidColor(widget.sound.element).withOpacity(0.5),
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
    required VoidCallback onPressed,
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