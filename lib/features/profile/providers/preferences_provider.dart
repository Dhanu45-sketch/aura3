import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/image_service.dart';

class PreferencesProvider extends ChangeNotifier {
  // REVERTED: Using global singletons to restore original app architecture
  final StorageService _storage = storageService;
  final ImageService _imageService = imageService;

  String _themeMode = 'dark';
  bool _autoPlay = true;
  String _downloadQuality = 'high';
  int _sleepTimerDefault = 30;
  bool _notificationsEnabled = true;
  String? _profilePictureUrl;

  int _totalListeningTime = 0;
  int _streak = 0;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  // Getters
  String get themeMode => _themeMode;
  bool get autoPlay => _autoPlay;
  String get downloadQuality => _downloadQuality;
  int get sleepTimerDefault => _sleepTimerDefault;
  bool get notificationsEnabled => _notificationsEnabled;
  String? get profilePictureUrl => _profilePictureUrl;
  int get totalListeningTime => _totalListeningTime;
  int get streak => _streak;
  bool get isLoading => _isLoading;
  bool get isUploadingImage => _isUploadingImage;

  // REVERTED: Constructor no longer takes services as arguments
  PreferencesProvider() {
    _loadPreferences();
  }

  // CORRECTED: Made method async and added await to all calls
  Future<void> _loadPreferences() async {
    _isLoading = true;
    notifyListeners();

    try {
      _themeMode = await _storage.getThemeMode();
      _autoPlay = await _storage.getAutoPlay();
      _downloadQuality = await _storage.getDownloadQuality();
      _sleepTimerDefault = await _storage.getSleepTimerDefault();
      _notificationsEnabled = await _storage.getNotificationsEnabled();
      _profilePictureUrl = await _storage.getProfilePictureUrl();
      _totalListeningTime = await _storage.getTotalListeningTime();
      _streak = await _storage.getStreak();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Theme Mode
  Future<void> setThemeMode(String mode) async {
    try {
      await _storage.setThemeMode(mode);
      _themeMode = mode;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting theme mode: $e');
    }
  }

  // Auto Play
  Future<void> setAutoPlay(bool value) async {
    try {
      await _storage.setAutoPlay(value);
      _autoPlay = value;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting auto play: $e');
    }
  }

  // Download Quality
  Future<void> setDownloadQuality(String quality) async {
    try {
      await _storage.setDownloadQuality(quality);
      _downloadQuality = quality;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting download quality: $e');
    }
  }

  // Sleep Timer Default
  Future<void> setSleepTimerDefault(int minutes) async {
    try {
      await _storage.setSleepTimerDefault(minutes);
      _sleepTimerDefault = minutes;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting sleep timer default: $e');
    }
  }

  // Notifications
  Future<void> setNotificationsEnabled(bool value) async {
    try {
      await _storage.setNotificationsEnabled(value);
      _notificationsEnabled = value;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting notifications: $e');
    }
  }

  // Add listening session
  Future<void> addListeningSession(String soundId, int durationSeconds) async {
    try {
      await _storage.addListeningSession(soundId, durationSeconds);
      _totalListeningTime += durationSeconds;
      // CORRECTED: Added await for the async call
      _streak = await _storage.getStreak();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding listening session: $e');
    }
  }

  // Get formatted listening time
  String get formattedListeningTime {
    final hours = _totalListeningTime ~/ 3600;
    final minutes = (_totalListeningTime % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Clear history
  Future<void> clearHistory() async {
    try {
      await _storage.clearHistory();
      _totalListeningTime = 0;
      _streak = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }

  // CORRECTED: Added await
  Future<void> reload() async {
    await _loadPreferences();
  }

  // Profile Picture Management
  Future<bool> updateProfilePictureFromCamera(String userId) async {
    return _updateProfilePicture(userId, _imageService.pickImageFromCamera);
  }

  Future<bool> updateProfilePictureFromGallery(String userId) async {
    return _updateProfilePicture(userId, _imageService.pickImageFromGallery);
  }

  Future<bool> _updateProfilePicture(
      String userId, Future<File?> Function() pickImage) async {
    _isUploadingImage = true;
    notifyListeners();

    try {
      final imageFile = await pickImage();
      if (imageFile == null) {
        _isUploadingImage = false;
        notifyListeners();
        return false;
      }

      // Delete old profile picture if exists
      if (_profilePictureUrl != null) {
        await _imageService.deleteProfilePicture(_profilePictureUrl!);
      }

      // Upload new picture
      final downloadUrl = await _imageService.uploadProfilePicture(imageFile, userId);
      if (downloadUrl != null) {
        await _storage.setProfilePictureUrl(downloadUrl);
        _profilePictureUrl = downloadUrl;
        _isUploadingImage = false;
        notifyListeners();
        return true;
      }

      _isUploadingImage = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
      _isUploadingImage = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeProfilePicture() async {
    try {
      if (_profilePictureUrl != null) {
        await _imageService.deleteProfilePicture(_profilePictureUrl!);
        await _storage.removeProfilePicture();
        _profilePictureUrl = null;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error removing profile picture: $e');
      return false;
    }
  }
}
