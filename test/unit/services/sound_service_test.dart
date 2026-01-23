import 'package:flutter_test/flutter_test.dart';
import 'package:aura3/core/services/sound_service.dart';
import 'package:aura3/core/models/sound.dart';
import '../../mocks/mock_data.dart';

void main() {
  late SoundService soundService;

  setUp(() {
    // Direct instantiation - uses global singleton internally or creates new
    soundService = SoundService();
  });

  group('SoundService - Local Logic', () {
    test('filters sounds by element correctly', () {
      final sounds = MockData.mockSounds;
      final results = soundService.getSoundsByElement(sounds, 'earth');
      
      expect(results, isNotEmpty);
      expect(results.every((s) => s.element == 'earth'), true);
    });

    test('getSoundById returns correct sound', () {
      final sounds = MockData.mockSounds;
      final target = sounds.first;
      
      final result = soundService.getSoundById(sounds, target.id);
      
      expect(result?.id, equals(target.id));
    });

    test('searchSounds finds by title', () {
      final sounds = MockData.mockSounds;
      final query = 'Rain';
      
      final results = soundService.searchSounds(sounds, query);
      
      expect(results.any((s) => s.title.contains('Rain')), true);
    });
  });

  group('SoundService - Cache Management', () {
    test('clearCache resets state', () {
      soundService.clearCache();
      final info = soundService.getCacheInfo();
      expect(info['hasCachedData'], false);
    });
  });
}
