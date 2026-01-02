import 'package:flutter/foundation.dart';
import '../../../core/models/sound.dart';
import '../../sounds/providers/sound_provider.dart';
import '../../library/providers/playlist_provider.dart';

class FavoritesProvider extends ChangeNotifier {
  SoundProvider? _soundProvider;
  PlaylistProvider? _playlistProvider;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  FavoritesProvider();

  // Called by ProxyProvider to link providers
  void updateDependencies(
      SoundProvider soundProvider,
      PlaylistProvider playlistProvider,
      ) {
    _soundProvider = soundProvider;
    _playlistProvider = playlistProvider;
  }

  // Check if sound is favorited
  bool isFavorite(String soundId) {
    if (_playlistProvider == null) return false;
    return _playlistProvider!.isInFavorites(soundId);
  }

  // Toggle favorite
  Future<void> toggleFavorite(String soundId) async {
    if (_playlistProvider == null) return;

    try {
      if (isFavorite(soundId)) {
        await _playlistProvider!.removeFromFavorites(soundId);
        debugPrint('Removed from favorites: $soundId');
      } else {
        await _playlistProvider!.addToFavorites(soundId);
        debugPrint('Added to favorites: $soundId');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  // Add to recently played
  Future<void> addRecentlyPlayed(String soundId) async {
    if (_playlistProvider == null) return;

    try {
      await _playlistProvider!.addToRecentlyPlayed(soundId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding recently played: $e');
    }
  }

  // Get favorite sounds
  List<Sound> getFavoriteSounds() {
    if (_soundProvider == null || _playlistProvider == null) return [];
    return _playlistProvider!.getSoundsForPlaylist('favorites');
  }

  // Get recently played sounds
  List<Sound> getRecentlyPlayedSounds() {
    if (_soundProvider == null || _playlistProvider == null) return [];
    return _playlistProvider!.getSoundsForPlaylist('recently_played');
  }

  // Clear favorites
  Future<void> clearFavorites() async {
    if (_playlistProvider == null) return;

    try {
      final favorites = _playlistProvider!.favoritesPlaylist;
      if (favorites != null) {
        for (final soundId in [...favorites.soundIds]) {
          await _playlistProvider!.removeFromFavorites(soundId);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }
  }

  Future<void> reload() async {
    // Playlists are managed by PlaylistProvider
    notifyListeners();
  }
}