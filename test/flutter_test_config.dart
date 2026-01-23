import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Global test configuration for Aura 3
/// This file is automatically loaded before any tests run

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Set default test timeout
  setUpAll(() {
    // Configure default timeout for all tests
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  // Set up global test configuration
  setUp(() {
    // Reset any global state before each test
    debugPrint('=== Starting Test ===');
  });

  tearDown(() {
    // Clean up after each test
    debugPrint('=== Test Complete ===');
  });

  // Run the actual test
  await testMain();
}

/// Custom test timeout (30 seconds default)
const defaultTestTimeout = Timeout(Duration(seconds: 30));

/// Custom integration test timeout (2 minutes)
const integrationTestTimeout = Timeout(Duration(minutes: 2));
