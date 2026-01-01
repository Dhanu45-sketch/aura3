import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sound.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _recentlyPlayedKey = 'recently_played';
  static const String _listeningHistoryKey = 'listening_history';
  static const String _totalListeningTimeKey = 'total_listening_time';
  static const String _streakKey = 'streak';
  static const String _lastPlayedDateKey = 'last_played_date';

  // Preferences keys
  static const String _themeKey = 'theme_mode';
  static const String _autoPlayKey = 'auto_play';
  static const String _downloadQualityKey = 'download_quality';
  static const String _sleepTimerDefaultKey = 'sleep_timer_default';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _profilePictureKey = 'profile_picture_url';

  SharedPreferences? _prefs;

  // Initialize
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Get SharedPreferences instance
  Future<SharedPreferences> get _instance async {
    await init();
    return _prefs!;
  }

  // ========== FAVORITES ==========

  Future<List<String>> getFavorites() async {
    final prefs = await _instance;
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    return favoritesJson;
  }

  Future<bool> addFavorite(String soundId) async {
    final prefs = await _instance;
    final favorites = await getFavorites();
    if (!favorites.contains(soundId)) {
      favorites.add(soundId);
      return await prefs.setStringList(_favoritesKey, favorites);
    }
    return false;
  }

  Future<bool> removeFavorite(String soundId) async {
    final prefs = await _instance;
    final favorites = await getFavorites();
    favorites.remove(soundId);
    return await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<bool> isFavorite(String soundId) async {
    final favorites = await getFavorites();
    return favorites.contains(soundId);
  }

  Future<bool> toggleFavorite(String soundId) async {
    if (await isFavorite(soundId)) {
      return await removeFavorite(soundId);
    } else {
      return await addFavorite(soundId);
    }
  }

  // ========== RECENTLY PLAYED ==========

  Future<List<String>> getRecentlyPlayed() async {
    final prefs = await _instance;
    return prefs.getStringList(_recentlyPlayedKey) ?? [];
  }

  Future<bool> addRecentlyPlayed(String soundId) async {
    final prefs = await _instance;
    final recent = await getRecentlyPlayed();

    // Remove if already exists
    recent.remove(soundId);

    // Add to beginning
    recent.insert(0, soundId);

    // Keep only last 20
    if (recent.length > 20) {
      recent.removeRange(20, recent.length);
    }

    return await prefs.setStringList(_recentlyPlayedKey, recent);
  }

  // ========== LISTENING HISTORY ==========

  Future<Map<String, dynamic>> getListeningHistory() async {
    final prefs = await _instance;
    final historyJson = prefs.getString(_listeningHistoryKey);
    if (historyJson == null) return {};
    return json.decode(historyJson) as Map<String, dynamic>;
  }

  Future<bool> addListeningSession(String soundId, int durationSeconds) async {
    final prefs = await _instance;
    final history = await getListeningHistory();

    // Update count for this sound
    final soundData = history[soundId] as Map<String, dynamic>? ?? {
      'count': 0,
      'totalSeconds': 0,
    };

    soundData['count'] = (soundData['count'] as int) + 1;
    soundData['totalSeconds'] = (soundData['totalSeconds'] as int) + durationSeconds;
    history[soundId] = soundData;

    await prefs.setString(_listeningHistoryKey, json.encode(history));

    // Update total listening time
    await _updateTotalListeningTime(durationSeconds);

    // Update streak
    await _updateStreak();

    return true;
  }

  // ========== STATISTICS ==========

  Future<int> getTotalListeningTime() async {
    final prefs = await _instance;
    return prefs.getInt(_totalListeningTimeKey) ?? 0;
  }

  Future<void> _updateTotalListeningTime(int seconds) async {
    final prefs = await _instance;
    final total = await getTotalListeningTime();
    await prefs.setInt(_totalListeningTimeKey, total + seconds);
  }

  Future<int> getStreak() async {
    final prefs = await _instance;
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> _updateStreak() async {
    final prefs = await _instance;
    final lastPlayedStr = prefs.getString(_lastPlayedDateKey);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    if (lastPlayedStr == null) {
      // First time
      await prefs.setInt(_streakKey, 1);
      await prefs.setString(_lastPlayedDateKey, todayStr);
    } else if (lastPlayedStr != todayStr) {
      final lastPlayed = DateTime.parse(lastPlayedStr.replaceAll('-', ''));
      final difference = today.difference(lastPlayed).inDays;

      if (difference == 1) {
        // Consecutive day
        final streak = await getStreak();
        await prefs.setInt(_streakKey, streak + 1);
      } else if (difference > 1) {
        // Streak broken
        await prefs.setInt(_streakKey, 1);
      }

      await prefs.setString(_lastPlayedDateKey, todayStr);
    }
  }

  // ========== PREFERENCES ==========

  Future<String> getThemeMode() async {
    final prefs = await _instance;
    return prefs.getString(_themeKey) ?? 'dark';
  }

  Future<bool> setThemeMode(String mode) async {
    final prefs = await _instance;
    return await prefs.setString(_themeKey, mode);
  }

  Future<bool> getAutoPlay() async {
    final prefs = await _instance;
    return prefs.getBool(_autoPlayKey) ?? true;
  }

  Future<bool> setAutoPlay(bool value) async {
    final prefs = await _instance;
    return await prefs.setBool(_autoPlayKey, value);
  }

  Future<String> getDownloadQuality() async {
    final prefs = await _instance;
    return prefs.getString(_downloadQualityKey) ?? 'high';
  }

  Future<bool> setDownloadQuality(String quality) async {
    final prefs = await _instance;
    return await prefs.setString(_downloadQualityKey, quality);
  }

  Future<int> getSleepTimerDefault() async {
    final prefs = await _instance;
    return prefs.getInt(_sleepTimerDefaultKey) ?? 30;
  }

  Future<bool> setSleepTimerDefault(int minutes) async {
    final prefs = await _instance;
    return await prefs.setInt(_sleepTimerDefaultKey, minutes);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await _instance;
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<bool> setNotificationsEnabled(bool value) async {
    final prefs = await _instance;
    return await prefs.setBool(_notificationsKey, value);
  }

  // Profile Picture
  Future<String?> getProfilePictureUrl() async {
    final prefs = await _instance;
    return prefs.getString(_profilePictureKey);
  }

  Future<bool> setProfilePictureUrl(String url) async {
    final prefs = await _instance;
    return await prefs.setString(_profilePictureKey, url);
  }

  Future<bool> removeProfilePicture() async {
    final prefs = await _instance;
    return await prefs.remove(_profilePictureKey);
  }

  static const String _downloadedSoundsKey = 'downloaded_sounds';

  // ========== DOWNLOADED SOUNDS ==========

  Future<List<String>> getDownloadedSounds() async {
    final prefs = await _instance;
    return prefs.getStringList(_downloadedSoundsKey) ?? [];
  }

  Future<bool> setDownloadedSounds(List<String> soundIds) async {
    final prefs = await _instance;
    return await prefs.setStringList(_downloadedSoundsKey, soundIds);
  }

  Future<bool> addDownloadedSound(String soundId) async {
    final prefs = await _instance;
    final downloaded = await getDownloadedSounds();
    if (!downloaded.contains(soundId)) {
      downloaded.add(soundId);
      return await prefs.setStringList(_downloadedSoundsKey, downloaded);
    }
    return false;
  }

  Future<bool> removeDownloadedSound(String soundId) async {
    final prefs = await _instance;
    final downloaded = await getDownloadedSounds();
    downloaded.remove(soundId);
    return await prefs.setStringList(_downloadedSoundsKey, downloaded);
  }

  Future<bool> isDownloaded(String soundId) async {
    final downloaded = await getDownloadedSounds();
    return downloaded.contains(soundId);
  }

  Future<bool> clearDownloadedSounds() async {
    final prefs = await _instance;
    return await prefs.remove(_downloadedSoundsKey);
  }
  static const String _meditationProgressKey = 'meditation_progress';

  // ========== MEDITATION PROGRESS ==========

  Future<Map<String, int>> getMeditationProgress() async {
    final prefs = await _instance;
    final progressJson = prefs.getString(_meditationProgressKey);

    if (progressJson == null) return {};

    try {
      final decoded = json.decode(progressJson) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      debugPrint('Error decoding meditation progress: $e');
      return {};
    }
  }

  Future<bool> setMeditationProgress(Map<String, int> progress) async {
    final prefs = await _instance;
    final progressJson = json.encode(progress);
    return await prefs.setString(_meditationProgressKey, progressJson);
  }

  Future<int> getProgramProgress(String programId) async {
    final progress = await getMeditationProgress();
    return progress[programId] ?? 0;
  }

  Future<bool> setProgramProgress(String programId, int day) async {
    final progress = await getMeditationProgress();
    progress[programId] = day;
    return await setMeditationProgress(progress);
  }

  Future<bool> clearMeditationProgress() async {
    final prefs = await _instance;
    return await prefs.remove(_meditationProgressKey);
  }


  // ========== CLEAR DATA ==========

  Future<bool> clearAllData() async {
    final prefs = await _instance;
    return await prefs.clear();
  }

  Future<bool> clearFavorites() async {
    final prefs = await _instance;
    return await prefs.remove(_favoritesKey);
  }

  Future<bool> clearHistory() async {
    final prefs = await _instance;
    await prefs.remove(_recentlyPlayedKey);
    await prefs.remove(_listeningHistoryKey);
    await prefs.remove(_totalListeningTimeKey);
    await prefs.remove(_streakKey);
    await prefs.remove(_lastPlayedDateKey);
    return true;
  }
}

// Singleton instance
final storageService = StorageService();
