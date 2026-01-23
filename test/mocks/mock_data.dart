import 'package:aura3/core/models/sound.dart';
import 'package:aura3/core/models/meditation_program.dart';
import 'package:aura3/core/models/playlist.dart';

class MockData {
  // Mock Sounds
  static final List<Sound> mockSounds = [
    Sound(
      id: 'earth_001',
      title: 'Bangkok Rain',
      element: 'earth',
      description: 'Gentle rain sounds from Bangkok',
      durationSeconds: 180,
      firebaseStoragePath: 'sounds/earth/rain.wav',
      thumbnailUrl: '',
      tags: ['rain', 'nature', 'sleep'],
      isPremium: false,
      fileSize: '5.2 MB',
      format: 'WAV',
    ),
    Sound(
      id: 'fire_001',
      title: 'Cozy Fireplace',
      element: 'fire',
      description: 'Crackling fireplace sounds',
      durationSeconds: 240,
      firebaseStoragePath: 'sounds/fire/fireplace.aiff',
      thumbnailUrl: '',
      tags: ['fireplace', 'cozy', 'winter'],
      isPremium: false,
      fileSize: '7.5 MB',
      format: 'AIFF',
    ),
    Sound(
      id: 'water_001',
      title: 'Ocean Waves',
      element: 'water',
      description: 'Calming ocean waves',
      durationSeconds: 200,
      firebaseStoragePath: 'sounds/water/ocean.wav',
      thumbnailUrl: '',
      tags: ['ocean', 'waves', 'beach'],
      isPremium: false,
      fileSize: '6.2 MB',
      format: 'WAV',
    ),
    Sound(
      id: 'wind_001',
      title: 'Windchimes',
      element: 'wind',
      description: 'Soothing windchimes',
      durationSeconds: 220,
      firebaseStoragePath: 'sounds/wind/windchimes.wav',
      thumbnailUrl: '',
      tags: ['windchimes', 'peaceful', 'zen'],
      isPremium: false,
      fileSize: '7.0 MB',
      format: 'WAV',
    ),
  ];

  // Create custom mock sound
  static Sound createMockSound(String id, {
    String? element,
    String? title,
    int? duration,
    bool? isPremium,
  }) {
    return Sound(
      id: id,
      title: title ?? 'Test Sound $id',
      element: element ?? 'earth',
      description: 'Test description for $id',
      durationSeconds: duration ?? 180,
      firebaseStoragePath: 'sounds/test/$id.wav',
      thumbnailUrl: '',
      tags: ['test', 'mock'],
      isPremium: isPremium ?? false,
      fileSize: '5.0 MB',
      format: 'WAV',
    );
  }

  // Mock Meditation Programs
  static final List<MeditationProgram> mockMeditationPrograms = [
    MeditationProgram(
      id: 'beginner_7day',
      title: '7-Day Calm Journey',
      description: 'Perfect for beginners',
      level: 'beginner',
      totalDays: 7,
      sessions: [
        MeditationSession(
          day: 1,
          title: 'Introduction to Breath',
          instruction: 'Focus on your natural breath...',
          recommendedSoundId: 'water_001',
          durationSeconds: 300,
        ),
        MeditationSession(
          day: 2,
          title: 'Body Awareness',
          instruction: 'Scan your body from toes to head...',
          recommendedSoundId: 'earth_001',
          durationSeconds: 420,
        ),
      ],
    ),
  ];

  // Mock Playlists
  static final List<Playlist> mockPlaylists = [
    Playlist(
      id: 'favorites',
      name: 'Favorites',
      description: 'Your favorite sounds',
      type: PlaylistType.favorites,
      soundIds: ['earth_001', 'water_001'],
    ),
    Playlist(
      id: 'earth',
      name: 'Earth Sounds',
      description: 'Nature and earth ambience',
      type: PlaylistType.element,
      soundIds: ['earth_001'],
      element: 'earth',
    ),
  ];

  // Mock User Data
  static const mockUserEmail = 'test@example.com';
  static const mockUserName = 'Test User';
  static const mockUserId = 'test-user-id-123';

  // Mock Statistics
  static const mockTotalListeningTime = 7200; // 2 hours in seconds
  static const mockStreak = 5;

  // Mock Preferences
  static const mockThemeMode = 'dark';
  static const mockAutoPlay = true;
  static const mockNotificationsEnabled = true;

  // Helper to create mock error messages
  static const networkError = 'Failed to connect to server';
  static const authError = 'Invalid credentials';
  static const storageError = 'Failed to save data';
  static const permissionError = 'Permission denied';

  // Helper to create lists of mock data
  static List<Sound> createMockSounds(int count, {String? element}) {
    return List.generate(
      count,
          (i) => createMockSound(
        'mock_$i',
        element: element,
      ),
    );
  }

  // Mock downloaded sound IDs
  static final List<String> mockDownloadedSoundIds = [
    'earth_001',
    'water_001',
  ];

  // Mock recent sound IDs
  static final List<String> mockRecentSoundIds = [
    'wind_001',
    'fire_001',
    'water_001',
  ];

  // Mock favorite sound IDs
  static final List<String> mockFavoriteSoundIds = [
    'earth_001',
    'water_001',
  ];

  // Mock listening history
  static final Map<String, Map<String, dynamic>> mockListeningHistory = {
    'earth_001': {'count': 5, 'totalSeconds': 900},
    'water_001': {'count': 3, 'totalSeconds': 600},
    'fire_001': {'count': 2, 'totalSeconds': 480},
  };

  // Mock meditation progress
  static final Map<String, int> mockMeditationProgress = {
    'beginner_7day': 3,
    'sleep_5day': 1,
  };

  // Mock connectivity info
  static final Map<String, dynamic> mockConnectivityInfo = {
    'isOnline': true,
    'connectionType': 'WiFi',
    'hasWifi': true,
    'hasMobile': false,
    'hasEthernet': false,
    'timestamp': DateTime.now().toIso8601String(),
  };

  // Mock Firebase Auth User
  static Map<String, dynamic> getMockUser() {
    return {
      'uid': mockUserId,
      'email': mockUserEmail,
      'displayName': mockUserName,
      'photoURL': null,
      'emailVerified': true,
    };
  }

  // Mock auth results
  static const mockAuthSuccessMessage = 'Successfully authenticated';
  static const mockAuthFailureMessage = 'Authentication failed';
  static const mockPasswordResetMessage = 'Password reset email sent';

  // Mock download progress
  static double mockDownloadProgress = 0.0;

  // Helper to simulate download progress
  static Stream<double> simulateDownloadProgress() async* {
    for (var i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      yield i / 100.0;
    }
  }

  // Mock API responses
  static Map<String, dynamic> getMockSoundsJsonResponse() {
    return {
      'version': '1.0.0',
      'sounds': mockSounds.map((s) => s.toJson()).toList(),
    };
  }

  static Map<String, dynamic> getMockProgramsJsonResponse() {
    return {
      'version': '1.0.0',
      'programs': mockMeditationPrograms.map((p) => p.toJson()).toList(),
    };
  }

  // Test data validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidDisplayName(String name) {
    return name.trim().length >= 2;
  }

  // Mock errors for testing error handling
  static Exception getMockNetworkException() {
    return Exception('Network request failed');
  }

  static Exception getMockAuthException() {
    return Exception('Authentication failed');
  }

  static Exception getMockStorageException() {
    return Exception('Storage operation failed');
  }
}