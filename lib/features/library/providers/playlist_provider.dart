import 'package:flutter/foundation.dart';
import '../../../core/models/sound.dart';
import '../../../core/models/playlist.dart';
import '../../../core/services/playlist_service.dart';
import '../../sounds/providers/sound_provider.dart';

class PlaylistProvider extends ChangeNotifier {
  final PlaylistService _playlistService = playlistService;
  SoundProvider? _soundProvider;

  List<Playlist> _playlists = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get specific playlists
  Playlist? get favoritesPlaylist =>
      _playlists.where((p) => p.type == PlaylistType.favorites).firstOrNull;
  Playlist? get downloadsPlaylist =>
      _playlists.where((p) => p.type == PlaylistType.downloads).firstOrNull;
  Playlist? get recentlyPlayedPlaylist =>
      _playlists.where((p) => p.type == PlaylistType.recentlyPlayed).firstOrNull;

  List<Playlist> get elementPlaylists =>
      _playlists.where((p) => p.type == PlaylistType.element).toList();

  PlaylistProvider() {
    _initialize();
  }

  // Link to SoundProvider
  void updateDependencies(SoundProvider soundProvider) {
    _soundProvider = soundProvider;
    _syncElementPlaylists();
  }

  Future<void> _initialize() async {
    await loadPlaylists();
  }

  // Load all playlists
  Future<void> loadPlaylists() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _playlists = await _playlistService.getPlaylists();
      await _syncElementPlaylists();
      debugPrint('Loaded ${_playlists.length} playlists');
    } catch (e) {
      _errorMessage = 'Failed to load playlists: ${e.toString()}';
      debugPrint(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Sync element playlists with available sounds
  Future<void> _syncElementPlaylists() async {
    if (_soundProvider == null) return;

    final elements = ['earth', 'fire', 'water', 'wind'];
    for (final element in elements) {
      final soundIds = _soundProvider!
          .getSoundsByElement(element)
          .map((sound) => sound.id)
          .toList();

      await _playlistService.syncElementPlaylists(soundIds, element);
    }

    // Reload playlists after sync
    _playlists = await _playlistService.getPlaylists();
    notifyListeners();
  }

  // Get playlist by ID
  Playlist? getPlaylistById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get playlist by element
  Playlist? getPlaylistByElement(String element) {
    try {
      return _playlists.firstWhere(
            (p) => p.type == PlaylistType.element && p.element == element,
      );
    } catch (e) {
      return null;
    }
  }

  // Get sounds for a playlist
  List<Sound> getSoundsForPlaylist(String playlistId) {
    if (_soundProvider == null) return [];

    final playlist = getPlaylistById(playlistId);
    if (playlist == null) return [];

    return playlist.soundIds
        .map((id) => _soundProvider!.getSoundById(id))
        .where((sound) => sound != null)
        .cast<Sound>()
        .toList();
  }

  // Add sound to playlist
  Future<bool> addSoundToPlaylist(String playlistId, String soundId) async {
    try {
      final success = await _playlistService.addSoundToPlaylist(playlistId, soundId);

      if (success) {
        _playlists = await _playlistService.getPlaylists();
        notifyListeners();
        debugPrint('Added sound $soundId to playlist $playlistId');
      }

      return success;
    } catch (e) {
      debugPrint('Error adding sound to playlist: $e');
      return false;
    }
  }

  // Remove sound from playlist
  Future<bool> removeSoundFromPlaylist(String playlistId, String soundId) async {
    try {
      final success = await _playlistService.removeSoundFromPlaylist(playlistId, soundId);

      if (success) {
        _playlists = await _playlistService.getPlaylists();
        notifyListeners();
        debugPrint('Removed sound $soundId from playlist $playlistId');
      }

      return success;
    } catch (e) {
      debugPrint('Error removing sound from playlist: $e');
      return false;
    }
  }

  // Add to favorites (convenience method)
  Future<bool> addToFavorites(String soundId) async {
    return await addSoundToPlaylist('favorites', soundId);
  }

  // Remove from favorites (convenience method)
  Future<bool> removeFromFavorites(String soundId) async {
    return await removeSoundFromPlaylist('favorites', soundId);
  }

  // Check if sound is in favorites
  bool isInFavorites(String soundId) {
    final favorites = favoritesPlaylist;
    return favorites?.contains(soundId) ?? false;
  }

  // Add to downloads (convenience method)
  Future<bool> addToDownloads(String soundId) async {
    return await addSoundToPlaylist('downloads', soundId);
  }

  // Remove from downloads (convenience method)
  Future<bool> removeFromDownloads(String soundId) async {
    return await removeSoundFromPlaylist('downloads', soundId);
  }

  // Check if sound is downloaded
  bool isDownloaded(String soundId) {
    final downloads = downloadsPlaylist;
    return downloads?.contains(soundId) ?? false;
  }

  // Add to recently played
  Future<bool> addToRecentlyPlayed(String soundId) async {
    final recentlyPlayed = recentlyPlayedPlaylist;
    if (recentlyPlayed == null) return false;

    // Remove if already exists
    final updatedSoundIds = recentlyPlayed.soundIds.where((id) => id != soundId).toList();

    // Add to beginning
    updatedSoundIds.insert(0, soundId);

    // Keep only last 20
    if (updatedSoundIds.length > 20) {
      updatedSoundIds.removeRange(20, updatedSoundIds.length);
    }

    final index = _playlists.indexWhere((p) => p.id == 'recently_played');
    if (index == -1) return false;

    _playlists[index] = recentlyPlayed.copyWith(
      soundIds: updatedSoundIds,
      updatedAt: DateTime.now(),
    );

    return await _playlistService.savePlaylists(_playlists);
  }

  // Get next sound in playlist
  Sound? getNextSound(String playlistId, String currentSoundId) {
    final playlist = getPlaylistById(playlistId);
    if (playlist == null || _soundProvider == null) return null;

    final currentIndex = playlist.soundIds.indexOf(currentSoundId);
    if (currentIndex == -1 || currentIndex >= playlist.soundIds.length - 1) {
      return null; // Not found or last track
    }

    final nextSoundId = playlist.soundIds[currentIndex + 1];
    return _soundProvider!.getSoundById(nextSoundId);
  }

  // Get previous sound in playlist
  Sound? getPreviousSound(String playlistId, String currentSoundId) {
    final playlist = getPlaylistById(playlistId);
    if (playlist == null || _soundProvider == null) return null;

    final currentIndex = playlist.soundIds.indexOf(currentSoundId);
    if (currentIndex <= 0) return null; // Not found or first track

    final previousSoundId = playlist.soundIds[currentIndex - 1];
    return _soundProvider!.getSoundById(previousSoundId);
  }

  // Check if has next track
  bool hasNext(String playlistId, String currentSoundId) {
    final playlist = getPlaylistById(playlistId);
    if (playlist == null) return false;

    final currentIndex = playlist.soundIds.indexOf(currentSoundId);
    return currentIndex != -1 && currentIndex < playlist.soundIds.length - 1;
  }

  // Check if has previous track
  bool hasPrevious(String playlistId, String currentSoundId) {
    final playlist = getPlaylistById(playlistId);
    if (playlist == null) return false;

    final currentIndex = playlist.soundIds.indexOf(currentSoundId);
    return currentIndex > 0;
  }

  // Reload playlists
  Future<void> reload() async {
    await loadPlaylists();
  }
}