import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sound.dart';
import 'connectivity_service.dart';

class SoundService {
  // IMPORTANT: Change this to your actual GitHub raw URL after you upload sounds.json
  // Example: 'https://raw.githubusercontent.com/yourusername/yourrepo/main/sounds.json'
  static const String externalJsonUrl =
      'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/sounds.json';

  static const String localJsonPath = 'assets/data/sounds.json';

  final ConnectivityService _connectivity = connectivityService;

  List<Sound> _cachedSounds = [];
  DateTime? _lastFetch;

  // Fetch sounds from external JSON or fallback to local
  Future<List<Sound>> getSounds() async {
    try {
      // Check if we have cached data (less than 1 hour old)
      if (_cachedSounds.isNotEmpty && _lastFetch != null) {
        final difference = DateTime.now().difference(_lastFetch!);
        if (difference.inMinutes < 60) {
          debugPrint('✅ Using cached sounds data (${_cachedSounds.length} sounds)');
          return _cachedSounds;
        }
      }

      // Check connectivity
      final isOnline = await _connectivity.checkConnectivity();

      if (isOnline) {
        debugPrint('🌐 Online: Attempting to fetch sounds from external JSON...');
        try {
          final sounds = await _fetchFromExternalJson();
          _cachedSounds = sounds;
          _lastFetch = DateTime.now();
          debugPrint('✅ Successfully fetched ${sounds.length} sounds from external JSON');
          return sounds;
        } catch (e) {
          debugPrint('❌ Failed to fetch from external JSON: $e');
          debugPrint('📱 Falling back to local JSON...');
          return await _fetchFromLocalJson();
        }
      } else {
        debugPrint('📴 Offline: Using local JSON...');
        return await _fetchFromLocalJson();
      }
    } catch (e) {
      debugPrint('❌ Error in getSounds: $e');
      throw Exception('Failed to load sounds: ${e.toString()}');
    }
  }

  // Fetch from external URL
  Future<List<Sound>> _fetchFromExternalJson() async {
    try {
      debugPrint('🔄 Fetching from URL: $externalJsonUrl');

      final response = await http.get(
        Uri.parse(externalJsonUrl),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out after 10 seconds');
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ HTTP 200 OK - Parsing JSON data...');
        final jsonData = json.decode(response.body);
        final sounds = _parseSoundsJson(jsonData);
        debugPrint('✅ Parsed ${sounds.length} sounds from external JSON');
        return sounds;
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to load external JSON');
      }
    } catch (e) {
      debugPrint('❌ External JSON fetch error: $e');
      rethrow;
    }
  }

  // Fetch from local assets
  Future<List<Sound>> _fetchFromLocalJson() async {
    try {
      debugPrint('📂 Loading from local asset: $localJsonPath');
      final jsonString = await rootBundle.loadString(localJsonPath);
      final jsonData = json.decode(jsonString);
      final sounds = _parseSoundsJson(jsonData);
      debugPrint('✅ Loaded ${sounds.length} sounds from local JSON');

      // Cache the local data too
      _cachedSounds = sounds;
      _lastFetch = DateTime.now();

      return sounds;
    } catch (e) {
      debugPrint('❌ Local JSON fetch error: $e');
      throw Exception('Failed to load local JSON: ${e.toString()}');
    }
  }

  // Parse JSON data to Sound objects
  List<Sound> _parseSoundsJson(Map<String, dynamic> jsonData) {
    try {
      // Check if the JSON has the expected structure
      if (!jsonData.containsKey('sounds')) {
        throw Exception('JSON does not contain "sounds" key');
      }

      final soundsList = jsonData['sounds'] as List<dynamic>;

      if (soundsList.isEmpty) {
        debugPrint('⚠️ Warning: Sounds list is empty');
        return [];
      }

      final sounds = soundsList
          .map((soundJson) {
        try {
          return Sound.fromJson(soundJson as Map<String, dynamic>);
        } catch (e) {
          debugPrint('⚠️ Warning: Failed to parse sound: $e');
          return null;
        }
      })
          .whereType<Sound>() // Filter out null values
          .toList();

      debugPrint('✅ Successfully parsed ${sounds.length} sounds');

      // Log version info if available
      if (jsonData.containsKey('version')) {
        debugPrint('📦 JSON Version: ${jsonData['version']}');
      }
      if (jsonData.containsKey('lastUpdated')) {
        debugPrint('📅 Last Updated: ${jsonData['lastUpdated']}');
      }

      return sounds;
    } catch (e) {
      debugPrint('❌ JSON parsing error: $e');
      throw Exception('Failed to parse sounds JSON: ${e.toString()}');
    }
  }

  // Force refresh from external source
  Future<List<Sound>> refreshSounds() async {
    debugPrint('🔄 Force refreshing sounds...');
    _cachedSounds.clear();
    _lastFetch = null;
    return await getSounds();
  }

  // Get sounds by element
  List<Sound> getSoundsByElement(List<Sound> sounds, String element) {
    return sounds
        .where((sound) => sound.element.toLowerCase() == element.toLowerCase())
        .toList();
  }

  // Get sound by ID
  Sound? getSoundById(List<Sound> sounds, String id) {
    try {
      return sounds.firstWhere((sound) => sound.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get sounds by tag
  List<Sound> getSoundsByTag(List<Sound> sounds, String tag) {
    return sounds
        .where((sound) => sound.tags
        .any((t) => t.toLowerCase() == tag.toLowerCase()))
        .toList();
  }

  // Search sounds
  List<Sound> searchSounds(List<Sound> sounds, String query) {
    if (query.isEmpty) return sounds;

    final lowerQuery = query.toLowerCase();
    return sounds.where((sound) {
      return sound.title.toLowerCase().contains(lowerQuery) ||
          sound.description.toLowerCase().contains(lowerQuery) ||
          sound.element.toLowerCase().contains(lowerQuery) ||
          sound.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Clear cache
  void clearCache() {
    debugPrint('🗑️ Clearing sounds cache...');
    _cachedSounds.clear();
    _lastFetch = null;
  }

  // Get cache info
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedData': _cachedSounds.isNotEmpty,
      'cachedSoundsCount': _cachedSounds.length,
      'lastFetchTime': _lastFetch?.toIso8601String(),
      'cacheAge': _lastFetch != null
          ? DateTime.now().difference(_lastFetch!).inMinutes
          : null,
    };
  }
}

// Global singleton instance
final soundService = SoundService();