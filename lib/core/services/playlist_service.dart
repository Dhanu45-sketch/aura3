import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';

class PlaylistService {
  static const String _playlistsKey = 'playlists';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _instance async {
    await init();
    return _prefs!;
  }

  // ========== LOAD & SAVE PLAYLISTS ==========

  Future<List<Playlist>> getPlaylists() async {
    try {
      final prefs = await _instance;
      final playlistsJson = prefs.getString(_playlistsKey);

      if (playlistsJson == null) {
        debugPrint('No playlists found, creating defaults');
        return await _createDefaultPlaylists();
      }

      final List<dynamic> decoded = json.decode(playlistsJson);
      final playlists = decoded
          .map((json) => Playlist.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('Loaded ${playlists.length} playlists');
      return playlists;
    } catch (e) {
      debugPrint('Error loading playlists: $e');
      return await _createDefaultPlaylists();
    }
  }

  Future<bool> savePlaylists(List<Playlist> playlists) async {
    try {
      final prefs = await _instance;
      final playlistsJson = json.encode(
        playlists.map((p) => p.toJson()).toList(),
      );
      final success = await prefs.setString(_playlistsKey, playlistsJson);
      debugPrint('Saved ${playlists.length} playlists: $success');
      return success;
    } catch (e) {
      debugPrint('Error saving playlists: $e');
      return false;
    }
  }

  // ========== CREATE DEFAULT PLAYLISTS ==========

  Future<List<Playlist>> _createDefaultPlaylists() async {
    final playlists = [
      // Element playlists
      Playlist(
        id: 'earth',
        name: 'Earth Sounds',
        description: 'Nature, forest, and earth ambience',
        type: PlaylistType.element,
        soundIds: [],
        element: 'earth',
      ),
      Playlist(
        id: 'fire',
        name: 'Fire Sounds',
        description: 'Crackling fires and warmth',
        type: PlaylistType.element,
        soundIds: [],
        element: 'fire',
      ),
      Playlist(
        id: 'water',
        name: 'Water Sounds',
        description: 'Ocean waves, rain, and flowing water',
        type: PlaylistType.element,
        soundIds: [],
        element: 'water',
      ),
      Playlist(
        id: 'wind',
        name: 'Wind Sounds',
        description: 'Breezes, windchimes, and air',
        type: PlaylistType.element,
        soundIds: [],
        element: 'wind',
      ),
      // Special playlists
      Playlist(
        id: 'favorites',
        name: 'Favorites',
        description: 'Your favorite sounds',
        type: PlaylistType.favorites,
        soundIds: [],
      ),
      Playlist(
        id: 'downloads',
        name: 'Downloads',
        description: 'Downloaded sounds for offline playback',
        type: PlaylistType.downloads,
        soundIds: [],
      ),
      Playlist(
        id: 'recently_played',
        name: 'Recently Played',
        description: 'Your recently played sounds',
        type: PlaylistType.recentlyPlayed,
        soundIds: [],
      ),
    ];

    await savePlaylists(playlists);
    return playlists;
  }

  // ========== PLAYLIST OPERATIONS ==========

  Future<Playlist?> getPlaylistById(String id) async {
    final playlists = await getPlaylists();
    try {
      return playlists.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addSoundToPlaylist(String playlistId, String soundId) async {
    try {
      final playlists = await getPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlistId);

      if (index == -1) return false;

      final playlist = playlists[index];
      if (playlist.soundIds.contains(soundId)) {
        debugPrint('Sound already in playlist');
        return true; // Already exists
      }

      final updatedSoundIds = [...playlist.soundIds, soundId];
      playlists[index] = playlist.copyWith(
        soundIds: updatedSoundIds,
        updatedAt: DateTime.now(),
      );

      return await savePlaylists(playlists);
    } catch (e) {
      debugPrint('Error adding sound to playlist: $e');
      return false;
    }
  }

  Future<bool> removeSoundFromPlaylist(String playlistId, String soundId) async {
    try {
      final playlists = await getPlaylists();
      final index = playlists.indexWhere((p) => p.id == playlistId);

      if (index == -1) return false;

      final playlist = playlists[index];
      final updatedSoundIds = playlist.soundIds.where((id) => id != soundId).toList();

      playlists[index] = playlist.copyWith(
        soundIds: updatedSoundIds,
        updatedAt: DateTime.now(),
      );

      return await savePlaylists(playlists);
    } catch (e) {
      debugPrint('Error removing sound from playlist: $e');
      return false;
    }
  }

  // ========== ELEMENT PLAYLIST SYNC ==========

  Future<bool> syncElementPlaylists(List<String> soundIds, String element) async {
    try {
      final playlists = await getPlaylists();
      final index = playlists.indexWhere((p) => p.element == element);

      if (index == -1) return false;

      playlists[index] = playlists[index].copyWith(
        soundIds: soundIds,
        updatedAt: DateTime.now(),
      );

      return await savePlaylists(playlists);
    } catch (e) {
      debugPrint('Error syncing element playlist: $e');
      return false;
    }
  }

  // ========== CLEAR DATA ==========

  Future<bool> clearPlaylists() async {
    try {
      final prefs = await _instance;
      return await prefs.remove(_playlistsKey);
    } catch (e) {
      debugPrint('Error clearing playlists: $e');
      return false;
    }
  }
}

// Global singleton
final playlistService = PlaylistService();