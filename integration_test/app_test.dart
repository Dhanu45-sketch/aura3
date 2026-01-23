import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:aura3/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Aura 3 Integration Journey', () {
    testWidgets('Login -> Meditate -> Library -> Profile -> Wind Player', (WidgetTester tester) async {
      const email = 'dhanushkasachintha@gmail.com';
      const password = '12345678';

      // Start App
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 1. LOGIN (If not already logged in)
      if (find.text('Welcome Back').evaluate().isNotEmpty) {
        debugPrint('--- STEP: Login ---');
        await tester.enterText(find.widgetWithText(TextField, 'Email'), email);
        await tester.enterText(find.widgetWithText(TextField, 'Password'), password);
        await tester.tap(find.text('Login'));
        // Wait for Firebase and Home transition
        await tester.pumpAndSettle(const Duration(seconds: 8));
      }

      // 2. MEDITATION
      debugPrint('--- STEP: Meditation ---');
      await tester.tap(find.text('Meditate'));
      await tester.pumpAndSettle();
      expect(find.text('Meditation'), findsWidgets);

      // 3. NAVIGATION (Library)
      debugPrint('--- STEP: Library ---');
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      expect(find.text('Library'), findsWidgets);

      // 4. PROFILE
      debugPrint('--- STEP: Profile ---');
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text(email), findsOneWidget);

      // 5. PLAYER (Wind Element 1)
      debugPrint('--- STEP: Player (Wind) ---');
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Find and tap Wind card (plays first track by default)
      final windCard = find.text('Wind');
      await tester.ensureVisible(windCard);
      await tester.tap(windCard);
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify player UI is open (check for the close button)
      expect(find.byIcon(Icons.expand_more_rounded), findsOneWidget);
      
      // Toggle Pause/Play
      final pauseBtn = find.byIcon(Icons.pause_rounded);
      if (pauseBtn.evaluate().isNotEmpty) {
        await tester.tap(pauseBtn.first);
        await tester.pumpAndSettle();
      }

      // Close player
      await tester.tap(find.byIcon(Icons.expand_more_rounded));
      await tester.pumpAndSettle();

      // 6. LOGOUT
      debugPrint('--- STEP: Logout ---');
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      
      final logoutBtn = find.text('Logout');
      await tester.scrollUntilVisible(logoutBtn, 500);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();
      
      // Confirm Logout in Dialog
      await tester.tap(find.text('Logout').last);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });
}
