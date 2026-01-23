import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura3/core/services/storage_service.dart';
import '../../mocks/mock_data.dart';

void main() {
  late StorageService storageService;

  setUp(() async {
    // Initialize SharedPreferences with empty values for testing
    SharedPreferences.setMockInitialValues({});
    storageService = StorageService();
    await storageService.init();
  });

  group('StorageService - Favorites', () {
    test('addFavorite and getFavorites logic', () async {
      const soundId = 'test_sound_1';
      
      await storageService.addFavorite(soundId);
      final favorites = await storageService.getFavorites();
      
      expect(favorites.contains(soundId), true);
    });

    test('removeFavorite removes sound ID', () async {
      const soundId = 'test_sound_1';
      await storageService.addFavorite(soundId);
      
      await storageService.removeFavorite(soundId);
      final favorites = await storageService.getFavorites();
      
      expect(favorites.contains(soundId), false);
    });

    test('isFavorite returns correct status', () async {
      const soundId = 'fav_sound';
      await storageService.addFavorite(soundId);
      
      expect(await storageService.isFavorite(soundId), true);
      expect(await storageService.isFavorite('other'), false);
    });
  });

  group('StorageService - Recently Played', () {
    test('addRecentlyPlayed manages list and limit', () async {
      await storageService.addRecentlyPlayed('sound1');
      await storageService.addRecentlyPlayed('sound2');
      await storageService.addRecentlyPlayed('sound1'); // Should move to front

      final recent = await storageService.getRecentlyPlayed();
      
      expect(recent.first, equals('sound1'));
      expect(recent.length, equals(2));
    });
  });

  group('StorageService - Preferences', () {
    test('setThemeMode and getThemeMode', () async {
      await storageService.setThemeMode('light');
      final mode = await storageService.getThemeMode();
      expect(mode, equals('light'));
    });

    test('setAutoPlay and getAutoPlay', () async {
      await storageService.setAutoPlay(false);
      final autoPlay = await storageService.getAutoPlay();
      expect(autoPlay, false);
    });
  });

  group('StorageService - Clear Data', () {
    test('clearAllData wipes everything', () async {
      await storageService.addFavorite('sound1');
      await storageService.setThemeMode('light');
      
      await storageService.clearAllData();
      
      expect(await storageService.getFavorites(), isEmpty);
      expect(await storageService.getThemeMode(), equals('dark')); // Default
    });
  });
}
