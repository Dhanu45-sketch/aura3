import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aura3/features/home/screens/home_screen.dart';
import 'package:aura3/features/sounds/providers/sound_provider.dart';
import 'package:aura3/features/library/providers/favorites_provider.dart';
import 'package:aura3/core/models/sound.dart';
import 'package:aura3/core/theme/app_theme.dart';

import '../../mocks/mock_data.dart';

void main() {
  // FIXED: Use Mock classes for variable types
  late MockSoundProvider mockSoundProvider;
  late MockFavoritesProvider mockFavoritesProvider;

  setUp(() {
    mockSoundProvider = MockSoundProvider();
    mockFavoritesProvider = MockFavoritesProvider();
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SoundProvider>.value(value: mockSoundProvider),
        ChangeNotifierProvider<FavoritesProvider>.value(value: mockFavoritesProvider),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('displays app title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Aura'), findsOneWidget);
    });

    testWidgets('displays welcome section with greeting', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate((widget) =>
        widget is Text &&
            (widget.data?.contains('Good') ?? false)
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('displays all four element cards', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Earth'), findsOneWidget);
      expect(find.text('Fire'), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Wind'), findsOneWidget);
    });

    testWidgets('expands element card when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Earth'));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('displays loading indicator when loading', (WidgetTester tester) async {
      mockSoundProvider.setLoading(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Start animation

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when error occurs', (WidgetTester tester) async {
      mockSoundProvider.setError('Failed to load sounds');

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.text('Failed to load sounds'), findsOneWidget);
    });

    testWidgets('displays retry button on error', (WidgetTester tester) async {
      mockSoundProvider.setError('Network error');

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button calls fetchSounds', (WidgetTester tester) async {
      mockSoundProvider.setError('Network error');
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(mockSoundProvider.fetchSoundsCalled, true);
    });

    testWidgets('sound tile shows favorite icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Earth'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsWidgets);
    });

    testWidgets('refresh button updates sounds', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();

      expect(mockSoundProvider.fetchSoundsCalled, true);
    });

    testWidgets('displays element icons correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.forest_rounded), findsOneWidget); // Earth
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget); // Fire
      expect(find.byIcon(Icons.water_drop_rounded), findsOneWidget); // Water
      expect(find.byIcon(Icons.air_rounded), findsOneWidget); // Wind
    });
  });
}

// Mock implementations
class MockSoundProvider extends ChangeNotifier implements SoundProvider {
  List<Sound> _sounds = MockData.mockSounds;
  bool _isLoading = false;
  String? _errorMessage;
  bool fetchSoundsCalled = false;

  @override List<Sound> get sounds => _sounds;
  @override bool get isLoading => _isLoading;
  @override String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void setManySounds(int count) {
    _sounds = List.generate(count, (i) => MockData.createMockSound('sound_$i'));
    notifyListeners();
  }

  @override
  Future<void> fetchSounds() async {
    fetchSoundsCalled = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  List<Sound> getSoundsByElement(String element) {
    return _sounds.where((s) => s.element == element).toList();
  }

  @override
  Sound? getSoundById(String id) {
    try {
      return _sounds.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override Future<void> refreshSounds() async {
    fetchSoundsCalled = true;
  }
  @override List<Sound> getSoundsByTag(String tag) => [];
  @override List<String> getAllTags() => [];
  @override List<Sound> searchSounds(String query) => [];
  @override List<Sound> getPremiumSounds() => [];
  @override List<Sound> getFreeSounds() => [];
  @override Duration getTotalDuration() => Duration.zero;
  @override String get formattedTotalDuration => '0m';
}

class MockFavoritesProvider extends ChangeNotifier implements FavoritesProvider {
  final Set<String> _favorites = {};

  @override bool isFavorite(String soundId) => _favorites.contains(soundId);
  @override Future<void> toggleFavorite(String soundId) async {
    if (_favorites.contains(soundId)) {
      _favorites.remove(soundId);
    } else {
      _favorites.add(soundId);
    }
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
