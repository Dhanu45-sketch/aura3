import 'package:flutter/foundation.dart';
import '../../../core/models/sound.dart';
import '../../../core/services/sound_service.dart';

class SoundProvider extends ChangeNotifier {
  final SoundService _soundService = SoundService();

  List<Sound> _sounds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Sound> get sounds => _sounds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SoundProvider() {
    fetchSounds();
  }

  Future<void> fetchSounds() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sounds = await _soundService.getSounds();
      debugPrint('Fetched ${_sounds.length} sounds successfully');
    } catch (e) {
      _errorMessage = 'Failed to load sounds: ${e.toString()}';
      debugPrint('Error fetching sounds: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Refresh sounds from external source
  Future<void> refreshSounds() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sounds = await _soundService.refreshSounds();
      debugPrint('Refreshed ${_sounds.length} sounds successfully');
    } catch (e) {
      _errorMessage = 'Failed to refresh sounds: ${e.toString()}';
      debugPrint('Error refreshing sounds: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Helper to get sounds by element
  List<Sound> getSoundsByElement(String element) {
    return _sounds.where((sound) =>
    sound.element.toLowerCase() == element.toLowerCase()
    ).toList();
  }

  // Helper to get a single sound by ID
  Sound? getSoundById(String id) {
    try {
      return _sounds.firstWhere((sound) => sound.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get sounds by tag
  List<Sound> getSoundsByTag(String tag) {
    return _sounds.where((sound) =>
        sound.tags.any((t) => t.toLowerCase() == tag.toLowerCase())
    ).toList();
  }

  // Get all unique tags
  List<String> getAllTags() {
    final allTags = <String>{};
    for (final sound in _sounds) {
      allTags.addAll(sound.tags);
    }
    return allTags.toList()..sort();
  }

  // Search sounds
  List<Sound> searchSounds(String query) {
    if (query.isEmpty) return _sounds;

    final lowerQuery = query.toLowerCase();
    return _sounds.where((sound) {
      return sound.title.toLowerCase().contains(lowerQuery) ||
          sound.description.toLowerCase().contains(lowerQuery) ||
          sound.element.toLowerCase().contains(lowerQuery) ||
          sound.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Get premium sounds
  List<Sound> getPremiumSounds() {
    return _sounds.where((sound) => sound.isPremium).toList();
  }

  // Get free sounds
  List<Sound> getFreeSounds() {
    return _sounds.where((sound) => !sound.isPremium).toList();
  }

  // Get total duration of all sounds
  Duration getTotalDuration() {
    final totalSeconds = _sounds.fold<int>(
        0,
            (sum, sound) => sum + sound.durationSeconds
    );
    return Duration(seconds: totalSeconds);
  }

  // Get formatted total duration
  String get formattedTotalDuration {
    final duration = getTotalDuration();
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}