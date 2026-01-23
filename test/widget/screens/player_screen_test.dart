import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aura3/features/player/screens/player_screen.dart';
import 'package:aura3/features/player/providers/audio_provider.dart';
import 'package:aura3/features/library/providers/favorites_provider.dart';
import 'package:aura3/features/profile/providers/preferences_provider.dart';
import 'package:aura3/core/models/sound.dart';
import 'package:aura3/core/theme/app_theme.dart';
import '../../mocks/mock_data.dart';

void main() {
  late MockAudioProvider mockAudioProvider;
  late MockFavoritesProvider mockFavoritesProvider;
  late MockPreferencesProvider mockPreferencesProvider;
  late List<Sound> testPlaylist;

  setUp(() {
    mockAudioProvider = MockAudioProvider();
    mockFavoritesProvider = MockFavoritesProvider();
    mockPreferencesProvider = MockPreferencesProvider();
    testPlaylist = MockData.mockSounds;
  });

  Widget createTestWidget({
    List<Sound>? playlist,
    int initialIndex = 0,
    String? playlistId,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioProvider>.value(value: mockAudioProvider),
        ChangeNotifierProvider<FavoritesProvider>.value(value: mockFavoritesProvider),
        ChangeNotifierProvider<PreferencesProvider>.value(value: mockPreferencesProvider),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: PlayerScreen(
          playlist: playlist ?? testPlaylist,
          initialIndex: initialIndex,
          playlistId: playlistId,
        ),
      ),
    );
  }

  group('PlayerScreen Widget Tests', () {
    testWidgets('displays sound title and description', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final sound = testPlaylist.first;
      expect(find.text(sound.title), findsOneWidget);
      expect(find.text(sound.description), findsOneWidget);
    });

    testWidgets('displays playback source as offline', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Offline'), findsOneWidget);
    });

    testWidgets('tapping favorite toggles state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final favoriteButton = find.byIcon(Icons.favorite_border).first;
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();

      expect(mockFavoritesProvider.toggleFavoriteCalled, true);
    });

    testWidgets('volume slider adjusts volume', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final slider = find.byType(Slider).last;
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      expect(mockAudioProvider.setVolumeCalled, true);
    });

    group('PlayerScreen State Tests', () {
      testWidgets('displays playlist info when available', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(playlistId: 'earth'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Earth Sounds'), findsOneWidget);
        expect(find.textContaining('Track 1 of'), findsOneWidget);
      });

      testWidgets('shows loading overlay when audio provider is loading', (WidgetTester tester) async {
        mockAudioProvider.setLoading(true);
        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Start animation

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });
}

// Mock Implementations
class MockAudioProvider extends ChangeNotifier implements AudioProvider {
  double _volume = 1.0;
  bool _isLoading = false;
  bool setVolumeCalled = false;

  @override bool get isLoading => _isLoading;
  @override String? get errorMessage => null;
  @override bool get isLooping => false;
  @override double get volume => _volume;
  @override Sound? get currentSound => MockData.mockSounds.first;
  @override bool get isPlaying => false;
  @override Duration get position => Duration.zero;
  @override Duration? get duration => const Duration(seconds: 180);
  @override String? get currentPlaylistId => null;
  @override List<Sound> get currentPlaylist => MockData.mockSounds;
  @override int get currentIndex => 0;
  @override bool get hasNext => true;
  @override bool get hasPrevious => false;
  @override double get progress => 0.0;
  @override Stream<Duration> get positionStream => Stream.value(Duration.zero);
  @override Stream<Duration?> get durationStream => Stream.value(const Duration(seconds: 180));
  @override Stream<bool> get playingStream => Stream.value(false);

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override Future<void> setVolume(double volume) async {
    setVolumeCalled = true;
    _volume = volume;
    notifyListeners();
  }

  @override Future<void> toggleLoop() async {}
  @override Future<void> playSound(Sound sound, {String? playlistId, List<Sound>? playlist}) async {}
  @override Future<void> playNext() async {}
  @override Future<void> playPrevious() async {}
  @override Future<void> togglePlayPause() async {}
  @override Future<void> pause() async {}
  @override Future<void> resume() async {}
  @override Future<void> stop() async {}
  @override Future<void> seek(Duration position) async {}
  @override Future<void> skipForward() async {}
  @override Future<void> skipBackward() async {}
  @override void clearError() {}
}

class MockFavoritesProvider extends ChangeNotifier implements FavoritesProvider {
  bool toggleFavoriteCalled = false;
  @override bool isFavorite(String soundId) => false;
  @override Future<void> toggleFavorite(String soundId) async {
    toggleFavoriteCalled = true;
    notifyListeners();
  }
  @override bool get isLoading => false;
  @override Future<void> addRecentlyPlayed(String soundId) async {}
  @override List<Sound> getFavoriteSounds() => [];
  @override List<Sound> getRecentlyPlayedSounds() => [];
  @override Future<void> clearFavorites() async {}
  @override Future<void> reload() async {}
  @override void updateDependencies(soundProvider, playlistProvider) {}
}

class MockPreferencesProvider extends ChangeNotifier implements PreferencesProvider {
  @override String get themeMode => 'dark';
  @override bool get autoPlay => true;
  @override String get downloadQuality => 'high';
  @override int get sleepTimerDefault => 30;
  @override bool get notificationsEnabled => true;
  @override String? get profilePictureUrl => null;
  @override int get totalListeningTime => 0;
  @override int get streak => 0;
  @override bool get isLoading => false;
  @override bool get isUploadingImage => false;
  @override String get formattedListeningTime => '0m';
  @override Future<void> setThemeMode(String mode) async {}
  @override Future<void> setAutoPlay(bool value) async {}
  @override Future<void> setDownloadQuality(String quality) async {}
  @override Future<void> setSleepTimerDefault(int minutes) async {}
  @override Future<void> setNotificationsEnabled(bool value) async {}
  @override Future<void> addListeningSession(String soundId, int durationSeconds) async {}
  @override Future<void> clearHistory() async {}
  @override Future<void> reload() async {}
  @override Future<bool> updateProfilePictureFromCamera(String userId) async => true;
  @override Future<bool> updateProfilePictureFromGallery(String userId) async => true;
  @override Future<bool> removeProfilePicture() async => true;
}
