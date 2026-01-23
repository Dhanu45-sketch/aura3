import 'package:flutter_test/flutter_test.dart';
import 'package:aura3/core/services/audio_service.dart';
import 'package:aura3/core/models/sound.dart';
import '../../mocks/mock_data.dart';

void main() {
  late AudioPlayerService audioService;

  setUp(() {
    // Direct instantiation - uses real AudioPlayer internally
    audioService = AudioPlayerService();
  });

  group('AudioPlayerService - Initialization', () {
    test('initializes successfully', () async {
      // Note: This may fail in unit tests as it accesses native platform channels
      await audioService.initialize();
      expect(audioService, isNotNull);
    });
  });

  group('AudioPlayerService - Basic State', () {
    test('currentSound is null initially', () {
      expect(audioService.currentSound, isNull);
    });

    test('throws exception when no audio source available', () async {
      final sound = Sound(
        id: 'no_source',
        title: 'No Source',
        element: 'earth',
        description: 'Test',
        durationSeconds: 180,
        thumbnailUrl: '',
        firebaseStoragePath: null,
        localAssetPath: null,
      );

      expect(
        () => audioService.playSound(sound),
        throwsException,
      );
    });
  });

  group('AudioPlayerService - Playback Logic', () {
    test('stop clears current sound', () async {
      // This test might hang or fail due to real AudioPlayer usage
      await audioService.stop();
      expect(audioService.currentSound, isNull);
    });
  });
}
