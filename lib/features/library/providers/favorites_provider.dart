import 'package:aura3/features/sounds/providers/sound_provider.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/sound.dart';

class FavoritesProvider extends ChangeNotifier {
  final StorageService _storage = storageService;
  SoundProvider? _soundProvider; // Will be updated by a ProxyProvider

  List<String> _favoriteIds = [];
  List<String> _recentlyPlayedIds = [];
  bool _isLoading = false;

  List<String> get favoriteIds => _favoriteIds;
  List<String> get recentlyPlayedIds => _recentlyPlayedIds;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    _loadData();
  }

  // Called by the ProxyProvider in main.dart to link the providers
  void updateDependencies(SoundProvider soundProvider) {
    _soundProvider = soundProvider;
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favoriteIds = await _storage.getFavorites();
      _recentlyPlayedIds = await _storage.getRecentlyPlayed();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  bool isFavorite(String soundId) {
    return _favoriteIds.contains(soundId);
  }

  Future<void> toggleFavorite(String soundId) async {
    try {
      await _storage.toggleFavorite(soundId);

      if (_favoriteIds.contains(soundId)) {
        _favoriteIds.remove(soundId);
      } else {
        _favoriteIds.add(soundId);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> addRecentlyPlayed(String soundId) async {
    try {
      await _storage.addRecentlyPlayed(soundId);

      _recentlyPlayedIds.remove(soundId);
      _recentlyPlayedIds.insert(0, soundId);

      if (_recentlyPlayedIds.length > 20) {
        _recentlyPlayedIds.removeRange(20, _recentlyPlayedIds.length);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding recently played: $e');
    }
  }

  // CORRECTED: No longer needs BuildContext
  List<Sound> getFavoriteSounds() {
    if (_soundProvider == null) return [];
    return _soundProvider!.sounds
        .where((sound) => _favoriteIds.contains(sound.id))
        .toList();
  }

  // CORRECTED: No longer needs BuildContext
  List<Sound> getRecentlyPlayedSounds() {
    if (_soundProvider == null) return [];
    return _recentlyPlayedIds
        .map((id) => _soundProvider!.getSoundById(id))
        .where((sound) => sound != null)
        .cast<Sound>()
        .toList();
  }

  Future<void> clearFavorites() async {
    try {
      await _storage.clearFavorites();
      _favoriteIds.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }
  }

  Future<void> reload() async {
    await _loadData();
  }
}
