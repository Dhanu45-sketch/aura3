import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Test helper utilities for Aura 3 tests

/// Pumps a widget with minimal Material setup
Future<void> pumpTestWidget(
    WidgetTester tester,
    Widget widget, {
      ThemeData? theme,
    }) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: widget),
    ),
  );
}

/// Pumps a widget with Provider setup
Future<void> pumpWithProviders(
    WidgetTester tester,
    Widget widget,
    List<ChangeNotifierProvider> providers, {
      ThemeData? theme,
    }) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: providers,
      child: MaterialApp(
        theme: theme,
        home: Scaffold(body: widget),
      ),
    ),
  );
}

/// Waits for animations to complete with timeout
Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
      Duration timeout = const Duration(seconds: 10),
    }) async {
  await tester.pumpAndSettle(timeout);
}

/// Finds text containing a substring (case insensitive)
Finder findTextContaining(String substring) {
  return find.byWidgetPredicate(
        (widget) =>
    widget is Text &&
        (widget.data?.toLowerCase().contains(substring.toLowerCase()) ?? false),
  );
}

/// Finds icon by its icon data
Finder findIconByData(IconData iconData) {
  return find.byWidgetPredicate(
        (widget) => widget is Icon && widget.icon == iconData,
  );
}

/// Scrolls until widget is visible
Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder, {
      double scrollAmount = 300,
      int maxScrolls = 50,
    }) async {
  for (var i = 0; i < maxScrolls; i++) {
    if (finder.evaluate().isNotEmpty) {
      break;
    }
    await tester.drag(find.byType(Scrollable).first, Offset(0, -scrollAmount));
    await tester.pumpAndSettle();
  }
}

/// Takes a screenshot for golden tests
Future<void> takeScreenshot(
    WidgetTester tester,
    String filename,
    ) async {
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$filename.png'),
  );
}

/// Verifies semantic labels exist
void verifySemantics(WidgetTester tester, Finder finder) {
  final SemanticsHandle handle = tester.ensureSemantics();
  expect(tester.getSemantics(finder), isNotNull);
  handle.dispose();
}

/// Simulates a tap with delay
Future<void> tapWithDelay(
    WidgetTester tester,
    Finder finder, {
      Duration delay = const Duration(milliseconds: 300),
    }) async {
  await tester.tap(finder);
  await tester.pump(delay);
  await tester.pumpAndSettle();
}

/// Simulates long press
Future<void> longPress(
    WidgetTester tester,
    Finder finder, {
      Duration duration = const Duration(seconds: 1),
    }) async {
  await tester.longPress(finder);
  await tester.pump(duration);
  await tester.pumpAndSettle();
}

/// Enters text with validation
Future<void> enterTextSafely(
    WidgetTester tester,
    Finder finder,
    String text,
    ) async {
  expect(finder, findsOneWidget);
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();

  // Verify text was entered
  final textField = tester.widget<TextField>(finder);
  expect(textField.controller?.text, equals(text));
}

/// Verifies error message is displayed
void expectErrorMessage(String message) {
  expect(find.text(message), findsOneWidget);
  expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
}

/// Verifies success message is displayed
void expectSuccessMessage(String message) {
  expect(find.text(message), findsOneWidget);
}

/// Verifies loading indicator
void expectLoadingIndicator() {
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
}

/// Verifies empty state
void expectEmptyState(String message) {
  expect(find.text(message), findsOneWidget);
}

/// Simulates network delay
Future<void> simulateNetworkDelay({
  Duration delay = const Duration(milliseconds: 500),
}) async {
  await Future.delayed(delay);
}

/// Verifies list has specific number of items
void expectListLength(Finder listFinder, int expectedLength) {
  final list = find.descendant(
    of: listFinder,
    matching: find.byType(ListTile),
  );
  expect(list, findsNWidgets(expectedLength));
}

/// Verifies navigation occurred
void expectNavigatedTo(Type screenType) {
  expect(find.byType(screenType), findsOneWidget);
}

/// Verifies dialog is shown
void expectDialog(String title) {
  expect(find.byType(AlertDialog), findsOneWidget);
  expect(find.text(title), findsOneWidget);
}

/// Verifies bottom sheet is shown
void expectBottomSheet(String title) {
  expect(find.text(title), findsOneWidget);
}

/// Verifies snackbar is shown
void expectBottomSheetSnackbar(String message) {
  expect(find.byType(SnackBar), findsOneWidget);
  expect(find.text(message), findsOneWidget);
}

/// Dismisses snackbar
Future<void> dismissSnackBar(WidgetTester tester) async {
  await tester.drag(find.byType(SnackBar), const Offset(0, 100));
  await tester.pumpAndSettle();
}

/// Dismisses dialog
Future<void> dismissDialog(WidgetTester tester) async {
  await tester.tap(find.text('Cancel'));
  await tester.pumpAndSettle();
}

/// Confirms dialog
Future<void> confirmDialog(WidgetTester tester, {String buttonText = 'OK'}) async {
  await tester.tap(find.text(buttonText));
  await tester.pumpAndSettle();
}

/// Verifies button is enabled
void expectButtonEnabled(Finder finder) {
  final button = find.descendant(
    of: finder,
    matching: find.byType(ElevatedButton),
  );
  expect(button, findsOneWidget);
  final widget = button.evaluate().first.widget as ElevatedButton;
  expect(widget.onPressed, isNotNull);
}

/// Verifies button is disabled
void expectButtonDisabled(Finder finder) {
  final button = find.descendant(
    of: finder,
    matching: find.byType(ElevatedButton),
  );
  expect(button, findsOneWidget);
  final widget = button.evaluate().first.widget as ElevatedButton;
  expect(widget.onPressed, isNull);
}

/// Measures widget build time
Future<Duration> measureBuildTime(
    WidgetTester tester,
    Widget widget,
    ) async {
  final stopwatch = Stopwatch()..start();
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
  stopwatch.stop();
  return stopwatch.elapsed;
}

/// Verifies performance benchmark
void expectPerformance(
    Duration actual,
    Duration threshold, {
      String? message,
    }) {
  expect(
    actual,
    lessThan(threshold),
    reason: message ?? 'Performance threshold exceeded: $actual > $threshold',
  );
}

/// Creates a test MediaQuery
Widget withMediaQuery(
    Widget child, {
      double width = 375,
      double height = 812,
      double textScale = 1.0,
    }) {
  return MediaQuery(
    data: MediaQueryData(
      size: Size(width, height),
      textScaler: TextScaler.linear(textScale),
    ),
    child: child,
  );
}

/// Simulates orientation change
Future<void> changeOrientation(
    WidgetTester tester,
    Orientation orientation,
    ) async {
  final size = orientation == Orientation.portrait
      ? const Size(375, 812)
      : const Size(812, 375);

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpAndSettle();
}

/// Resets orientation
void resetOrientation(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

/// Simulates system theme change
Future<void> changeSystemTheme(
    WidgetTester tester,
    Brightness brightness,
    ) async {
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  await tester.pumpAndSettle();
}

/// Verifies accessibility contrast
void expectSufficientContrast(Color foreground, Color background) {
  final contrast = _calculateContrastRatio(foreground, background);
  expect(
    contrast,
    greaterThanOrEqualTo(4.5),
    reason: 'Insufficient contrast ratio: $contrast',
  );
}

/// Calculates contrast ratio between two colors
double _calculateContrastRatio(Color foreground, Color background) {
  final l1 = _relativeLuminance(foreground);
  final l2 = _relativeLuminance(background);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Calculates relative luminance
double _relativeLuminance(Color color) {
  final r = _sRGBtoLin(color.r);
  final g = _sRGBtoLin(color.g);
  final b = _sRGBtoLin(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _sRGBtoLin(double colorChannel) {
  if (colorChannel <= 0.04045) {
    return colorChannel / 12.92;
  }
  return math.pow((colorChannel + 0.055) / 1.055, 2.4).toDouble();
}

/// Debug print widget tree
void printWidgetTree(WidgetTester tester) {
  debugDumpApp();
}

/// Debug print semantics tree
void printSemanticsTree(WidgetTester tester) {
  debugDumpSemanticsTree();
}

/// Creates a mock BuildContext
BuildContext createMockContext(WidgetTester tester) {
  return tester.element(find.byType(MaterialApp));
}
