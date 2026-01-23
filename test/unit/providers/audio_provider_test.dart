import 'package:flutter_test/flutter_test.dart';
import 'package:aura3/features/player/providers/audio_provider.dart';
import '../../mocks/mock_data.dart';

void main() {
  late AudioProvider audioProvider;

  setUp(() {
    // Direct instantiation - uses real AudioPlayerService internally
    audioProvider = AudioProvider();
  });

  group('AudioProvider - Playlist Logic', () {
    test('playSound updates current sound and index', () async {
      final playlist = MockData.mockSounds;
      final targetSound = playlist[1];

      // Note: This may throw if real service calls fail
      await audioProvider.playSound(targetSound, playlist: playlist);

      expect(audioProvider.currentSound?.id, equals(targetSound.id));
      expect(audioProvider.currentIndex, equals(1));
    });

    test('playNext updates index correctly', () async {
      final playlist = MockData.mockSounds;
      await audioProvider.playSound(playlist.first, playlist: playlist);

      await audioProvider.playNext();

      expect(audioProvider.currentIndex, equals(1));
      expect(audioProvider.currentSound?.id, equals(playlist[1].id));
    });

    test('hasNext reflects playlist position', () async {
      final playlist = MockData.mockSounds;
      
      await audioProvider.playSound(playlist.first, playlist: playlist);
      expect(audioProvider.hasNext, true);

      await audioProvider.playSound(playlist.last, playlist: playlist);
      expect(audioProvider.hasNext, false);
    });
  });

  group('AudioProvider - State Management', () {
    test('setVolume updates value and notifies listeners', () async {
      var notified = false;
      audioProvider.addListener(() => notified = true);

      await audioProvider.setVolume(0.7);

      expect(audioProvider.volume, equals(0.7));
      expect(notified, true);
    });

    test('toggleLoop switches state', () async {
      final initial = audioProvider.isLooping;
      await audioProvider.toggleLoop();
      expect(audioProvider.isLooping, equals(!initial));
    });
  });
}
