import 'package:flutter/foundation.dart';
import '../../../core/models/sound.dart';
import '../../../core/services/download_service.dart';
import '../../../core/services/storage_service.dart';

class DownloadProvider extends ChangeNotifier {
  final DownloadService _downloadService = downloadService;
  final StorageService _storage = storageService;

  // Track download progress for each sound
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _isDownloading = {};
  Set<String> _downloadedSoundIds = {};

  bool _isLoading = false;
  int _totalDownloadSize = 0;

  Map<String, double> get downloadProgress => _downloadProgress;
  Map<String, bool> get isDownloading => _isDownloading;
  Set<String> get downloadedSoundIds => _downloadedSoundIds;
  bool get isLoading => _isLoading;
  int get totalDownloadSize => _totalDownloadSize;

  String get formattedTotalSize => _downloadService.formatFileSize(_totalDownloadSize);

  DownloadProvider() {
    _loadDownloadedSounds();
  }

  // Load list of downloaded sounds on init
  Future<void> _loadDownloadedSounds() async {
    _isLoading = true;
    notifyListeners();

    try {
      final ids = await _downloadService.getDownloadedSoundIds();
      _downloadedSoundIds = Set.from(ids);
      _totalDownloadSize = await _downloadService.getTotalDownloadSize();
      debugPrint('Loaded ${_downloadedSoundIds.length} downloaded sounds');
    } catch (e) {
      debugPrint('Error loading downloaded sounds: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Check if a sound is downloaded
  bool isDownloaded(String soundId) {
    return _downloadedSoundIds.contains(soundId);
  }

  // Get download progress for a sound (0.0 to 1.0)
  double getProgress(String soundId) {
    return _downloadProgress[soundId] ?? 0.0;
  }

  // Check if currently downloading
  bool isDownloadingSound(String soundId) {
    return _isDownloading[soundId] ?? false;
  }

  // Download a sound
  Future<bool> downloadSound(Sound sound) async {
    if (_isDownloading[sound.id] == true) {
      debugPrint('Already downloading: ${sound.title}');
      return false;
    }

    _isDownloading[sound.id] = true;
    _downloadProgress[sound.id] = 0.0;
    notifyListeners();

    try {
      await _downloadService.downloadSound(
        sound,
        onProgress: (progress) {
          _downloadProgress[sound.id] = progress;
          notifyListeners();
        },
      );

      // Mark as downloaded
      _downloadedSoundIds.add(sound.id);
      _downloadProgress.remove(sound.id);
      _isDownloading[sound.id] = false;

      // Update total size
      _totalDownloadSize = await _downloadService.getTotalDownloadSize();

      // Save to storage
      await _saveDownloadedSounds();

      notifyListeners();
      debugPrint('Successfully downloaded: ${sound.title}');
      return true;
    } catch (e) {
      debugPrint('Failed to download ${sound.title}: $e');
      _downloadProgress.remove(sound.id);
      _isDownloading[sound.id] = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a downloaded sound
  Future<bool> deleteDownload(Sound sound) async {
    try {
      final success = await _downloadService.deleteDownload(sound);

      if (success) {
        _downloadedSoundIds.remove(sound.id);
        _totalDownloadSize = await _downloadService.getTotalDownloadSize();
        await _saveDownloadedSounds();
        notifyListeners();
        debugPrint('Deleted download: ${sound.title}');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting download: $e');
      return false;
    }
  }

  // Toggle download (download if not downloaded, delete if downloaded)
  Future<bool> toggleDownload(Sound sound) async {
    if (isDownloaded(sound.id)) {
      return await deleteDownload(sound);
    } else {
      return await downloadSound(sound);
    }
  }

  // Get local file path for a sound
  Future<String?> getLocalFilePath(Sound sound) async {
    if (!isDownloaded(sound.id)) return null;
    return await _downloadService.getLocalFilePath(sound);
  }

  // Clear all downloads
  Future<bool> clearAllDownloads() async {
    try {
      final success = await _downloadService.clearAllDownloads();

      if (success) {
        _downloadedSoundIds.clear();
        _downloadProgress.clear();
        _isDownloading.clear();
        _totalDownloadSize = 0;
        await _storage.clearDownloadedSounds();
        notifyListeners();
        debugPrint('Cleared all downloads');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error clearing downloads: $e');
      return false;
    }
  }

  // Save downloaded sound IDs to storage
  Future<void> _saveDownloadedSounds() async {
    try {
      await _storage.setDownloadedSounds(_downloadedSoundIds.toList());
    } catch (e) {
      debugPrint('Error saving downloaded sounds: $e');
    }
  }

  // Reload downloads
  Future<void> reload() async {
    await _loadDownloadedSounds();
  }
}